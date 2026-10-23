# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Widget output caching', type: :request do
  let(:form) { create(:form, :open_ended_form) }

  around do |example|
    original_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_store
  end

  before do
    # These tests exercise real after_commit invalidation. End the transaction
    # opened by rails_helper, then clean committed records with truncation.
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  def widget_body(id: form.short_uuid, locale: :en)
    get "/touchpoints/#{id}.js", params: { locale: }
    expect(response).to have_http_status(:ok)
    response.body.dup
  end

  def rendered_partials(&block)
    renders = []
    subscriber = ->(*args) { renders << args.last[:identifier] }
    ActiveSupport::Notifications.subscribed(subscriber, 'render_partial.action_view', &block)
    renders
  end

  it 'returns the same output on repeated requests' do
    first = widget_body
    expect(widget_body).to eq(first)
  end

  it 'does not render partials on cache hits' do
    widget_body
    expect(rendered_partials { widget_body }).to be_empty
  end

  it 'counts every request including cache hits' do
    2.times { widget_body }
    expect(form.reload.survey_form_activations).to eq(2)
  end

  it 'keeps legacy IDs working' do
    expected = widget_body
    expect(widget_body(id: form.legacy_touchpoint_id)).to eq(expected)
  end

  it 'keeps legacy UUIDs working' do
    expected = widget_body
    expect(widget_body(id: form.legacy_touchpoint_uuid)).to eq(expected)
  end

  it 'refreshes the widget after a form edit' do
    widget_body
    form.update!(title: 'Updated cached title')

    expect(widget_body).to include('Updated cached title')
  end

  it 'refreshes the widget after question edits' do
    widget_body
    form.questions.first.update!(text: 'Updated cached question')
    expect(widget_body).to include('Updated cached question')
  end

  it 'refreshes the widget after question deletions' do
    widget_body
    question = form.questions.first
    text = question.text
    question.destroy!
    expect(widget_body).not_to include(text)
  end

  context 'with a radio button question' do
    let(:question) { form.questions.first }
    let(:option) { question.question_options.create!(text: 'Initial option', value: 'initial', position: 1) }

    before { question.update!(question_type: 'radio_buttons') }

    it 'refreshes the widget after option creation' do
      widget_body
      option
      expect(widget_body).to include('Initial option')
    end

    it 'refreshes the widget after option editing' do
      option
      widget_body
      option.update!(text: 'Updated option')
      expect(widget_body).to include('Updated option')
    end

    it 'refreshes the widget after option deletion' do
      option
      widget_body
      option.destroy!
      expect(widget_body).not_to include('Initial option')
    end
  end

  it 'refreshes the widget after an empty section is deleted' do
    section = form.form_sections.create!(title: 'Removable section', position: 2)
    before = widget_body
    section.destroy!

    expect(widget_body).not_to eq(before)
  end

  context 'when a question moves between cached forms' do
    let(:other_form) { create(:form, organization: form.organization) }

    before do
      widget_body
      widget_body(id: other_form.short_uuid)
      form.questions.first.update!(form: other_form, form_section: other_form.form_sections.first)
    end

    it 'invalidates the source form' do
      expect(widget_body).not_to include('Test Open Area email')
    end

    it 'invalidates the destination form' do
      expect(widget_body(id: other_form.short_uuid)).to include('Test Open Area email')
    end
  end

  context 'when sections are reordered through the admin endpoint' do
    let(:first_section) { form.form_sections.first }
    let(:second_section) { form.form_sections.create!(title: 'Second section', position: 2) }
    let(:original_body) { widget_body }

    before do
      create(:question, form:, form_section: second_section, answer_field: 'answer_02', text: 'Second section question')
      original_body
      sign_in(create(:user, :admin, organization: form.organization))
      patch admin_form_form_section_sort_sections_path(form, first_section),
            params: { form_section: [second_section.id, first_section.id] }
    end

    it 'accepts the reorder' do
      expect(response).to have_http_status(:ok)
    end

    it 'refreshes the cached output' do
      expect(widget_body).not_to eq(original_body)
    end

    it 'renders questions in the updated section order' do
      body = widget_body
      expect(body.index('Second section question')).to be < body.index('Test Open Area email')
    end
  end

  it 'invalidates when the organization changes' do
    widget_body
    old_key = FormCache.widget_js_key(form.short_uuid, :en)
    form.organization.update!(name: 'Updated organization')

    expect(FormCache.widget_js_key(form.short_uuid, :en)).not_to eq(old_key)
  end

  context 'with cached English and Spanish output' do
    let(:english) { widget_body }
    let(:spanish) { widget_body(locale: :es) }

    before do
      english
      spanish
    end

    it 'renders distinct translations' do
      expect(spanish).not_to eq(english)
    end

    it 'preserves English output after requesting Spanish' do
      expect(widget_body).to eq(english)
    end

    it 'refreshes English output after an edit' do
      form.update!(title: 'New multilingual title')
      expect(widget_body).to include('New multilingual title')
    end

    it 'refreshes Spanish output after an edit' do
      form.update!(title: 'New multilingual title')
      expect(widget_body(locale: :es)).to include('New multilingual title')
    end
  end

  it 'bypasses caching for forms with CSRF enabled' do
    form.update!(verify_csrf: true)
    2.times { widget_body }

    expect(Rails.cache.read(FormCache.widget_js_key(form.short_uuid, :en))).to be_nil
  end
end
