# frozen_string_literal: true

class FormCache
  NAMESPACE = 'namespace:form-'

  # Hash the application, not a hand-maintained list of widget partials: helpers,
  # translations, model code and asset fingerprints can all change the output.
  WIDGET_SOURCE_PATTERNS = [
    'app/**/*',
    'config/**/*',
    'lib/**/*.rb',
    'ext/widget_renderer/src/**/*.rs',
    'db/schema.rb',
    'Gemfile.lock',
  ].freeze

  # Cache Store fetch will return the cached item
  # or run the block if the cached item does not exist
  def self.fetch(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch(NAMESPACE + short_uuid.to_s, expires_in: 1.day) do
      # Pull in all objects required to build a touchpoint
      Form.includes([:questions, { form_sections: [questions: [:question_options]] }], :organization).find_by_short_uuid(short_uuid)
    end
  end

  # Capture the revision BEFORE loading render data. An edit during rendering
  # changes the revision, so an in-flight old render only writes an obsolete key.
  # Revision keys are shared across releases; old output expires after an hour.
  def self.fetch_widget_js(form:, locale: I18n.locale)
    return yield if form.blank? || !form.persisted? || form.changed? || form.verify_csrf?

    key = widget_js_key(form.short_uuid, locale)
    cached = Rails.cache.read(key)
    return cached unless cached.nil?

    form.reload
    rendered = yield
    # Recheck after reload: CSRF may have been enabled since the initial lookup.
    Rails.cache.write(key, rendered, expires_in: 1.hour, compress: true) unless form.verify_csrf?
    rendered
  end

  def self.widget_js_key(short_uuid, locale)
    revision = Rails.cache.fetch(widget_revision_key(short_uuid)) { SecureRandom.uuid }
    "#{NAMESPACE}widget-js-#{widget_template_digest}-#{revision}-#{locale}-#{short_uuid}"
  end

  def self.widget_revision_key(short_uuid)
    "#{NAMESPACE}widget-revision-#{short_uuid}"
  end

  # Digest of every template and asset baked into the widget JS.
  #
  # Memoized outside development, where the files cannot change within the
  # lifetime of a running process. In development they can change while the
  # server is running, so the digest is recomputed to avoid serving stale JS to
  # a developer who has enabled caching locally.
  # Opt in to memoization for local load tests; restart after source/config edits.
  def self.widget_template_digest
    memoize = !Rails.env.development? || ENV.fetch('WIDGET_CACHE_MEMOIZE_DIGEST', nil) == 'true'
    return @widget_template_digest if @widget_template_digest && memoize

    @widget_template_digest = compute_widget_template_digest
  end

  def self.compute_widget_template_digest
    digest = Digest::SHA256.new
    WIDGET_SOURCE_PATTERNS.flat_map { |pattern| Rails.root.glob(pattern) }.uniq.sort.each do |path|
      next unless File.file?(path)

      digest << Pathname.new(path).relative_path_from(Rails.root).to_s << Digest::SHA256.file(path).hexdigest
    end

    digest << [
      Rails.env,
      Rails.application.config.action_controller.default_url_options,
      Rails.application.config.action_mailer.default_url_options,
      Rails.application.config.action_controller.asset_host,
      ENV.fetch('TURNSTILE_SITE_KEY', nil),
      ENV.fetch('DISABLE_RUST_RENDERER', nil),
      defined?(WidgetRenderer),
    ].to_json
    digest.hexdigest
  end

  def self.fetch_a11_analysis(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch("#{NAMESPACE}-a11-analysis-#{short_uuid}", expires_in: 1.day) do
      form = Form.find_by_short_uuid(short_uuid)
      report = {}
      report[:answer_01] = form.average_answer(:answer_01)
      report[:answer_02] = form.average_answer(:answer_02)
      report[:answer_03] = form.average_answer(:answer_03)
      report[:answer_04] = form.average_answer(:answer_04)
      report[:answer_05] = form.average_answer(:answer_05)
      report[:answer_06] = form.average_answer(:answer_06)
      report[:answer_07] = form.average_answer(:answer_07)
      report
    end
  end

  def self.fetch_performance_gov_analysis(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch("#{NAMESPACE}-performance-gov-analysis-#{short_uuid}", expires_in: 1.day) do
      form = Form.find_by_short_uuid(short_uuid)
      report = {}
      report[:quarterly_submissions] = form.submissions.entries.map { |e| e.attributes.merge(quarter: e.created_at.beginning_of_quarter.to_date, end_of_quarter: e.created_at.end_of_quarter) }
      report[:quarters] = report[:quarterly_submissions].pluck(:quarter).uniq
      report
    end
  end

  def self.invalidate(short_uuid)
    Rails.cache.delete(NAMESPACE + short_uuid.to_s)
    invalidate_widget_js(short_uuid)
  end

  # Rotate rather than delete output: a concurrent render cannot repopulate the
  # current key with stale content. One revision covers every locale and release.
  def self.invalidate_widget_js(short_uuid)
    Rails.cache.write(widget_revision_key(short_uuid), SecureRandom.uuid)
  end

  def self.invalidate_reports(short_uuid)
    Rails.cache.delete("#{NAMESPACE}-performance-gov-analysis-#{short_uuid}")
    Rails.cache.delete("#{NAMESPACE}-a11-analysis-#{short_uuid}")
  end
end
