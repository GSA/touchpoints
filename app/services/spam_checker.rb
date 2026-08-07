# frozen_string_literal: true

# Service object to run spam checks on a submission and return an overall outcome.
#
# Required context keys:
#   :referer  — String referer to validate (may be nil/blank)
#   :root_url — String root URL of the running application (may be nil)
#   :cf_turnstile_response — String token from the client (may be nil/blank)
#   :remote_ip             — String remote IP of the submitter
class SpamChecker
  DEFAULT_SPAM_CHECKS = SpamChecks::Base.checks

  # Value object returned from SpamChecker#call. Wraps the per-check results
  # and exposes the overall #verdict derived from them.
  class SpamResults
    attr_reader :results

    def initialize(results)
      @results = Array(results)
    end

    # Overall outcome derived from all checks, in precedence order:
    # a hard :reject wins, then :surface (maybe-bot-but-user-fixable, prompt a
    # retry), then :flag, otherwise :pass.
    def verdict
      if results.any?(&:reject?)
        :reject
      elsif results.any?(&:surface?)
        :surface
      elsif results.any?(&:flag?)
        :flag
      else
        :pass
      end
    end

    def flagged
      results.filter(&:flag?).map(&:name)
    end

    # Structured, JSON-serializable detail for each flagged check, keyed by
    # check name (e.g. { "referer" => { "referer" => "https://evil.example/" } }).
    # Used to reconstruct human-readable descriptions in the admin view.
    def flagged_context
      results.filter(&:flag?).each_with_object({}) do |result, hash|
        detail = result.context
        hash[result.name] = detail if detail.present?
      end
    end

    def applicable
      results.reject(&:not_applied?).map(&:name)
    end
  end

  def initialize(spam_checks: DEFAULT_SPAM_CHECKS)
    @spam_checks = spam_checks
  end

  def call(submission, context)
    # Run ALL applicable checks (not short-circuited) so the full outcome
    # vector is available for redundancy/co-occurrence analysis.
    spam_results = SpamResults.new(run_spam_checks(submission, context))
    record_spam_results(submission.form.id, spam_results)

    spam_results
  end

  private

  # Internal-only readers. These are set once in #initialize and used only
  # within the object, so they are not part of the public interface.
  attr_reader :spam_checks

  def run_spam_checks(submission, context)
    spam_checks.map do |check_class|
      check_class.new(submission: submission, context:).call
    end
  end

  # Record spam telemetry.
  def record_spam_results(form_id, spam_results)
    results = Array(spam_results.results)
    results_by_check = SpamChecks::Base.results_to_h(results)

    SpamMetrics.record(form_id:, verdict: spam_results.verdict, results: results_by_check)
  end
end
