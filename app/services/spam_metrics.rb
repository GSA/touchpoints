# frozen_string_literal: true

# SpamMetrics records the observability side effects for a spam check run on a submission.
# It is a plain object so the logic is unit-testable and is called directly from SpamChecker.
#
# Spam-prevention telemetry is treated as a **time-boxed analysis** — the goal is
# to measure how many submissions each prevention method blocks and whether
# methods are redundant (always block the same submissions), not to retain a
# durable audit trail. Accordingly, spam rejections are emitted to **NewRelic**
#   (the existing metrics backend) as counters plus a `SpamCheck` custom event
# with each check flattened to its own attribute, so both questions are
# answerable with NRQL `FACET` queries. NewRelic handles storage and retention.
module SpamMetrics
  module_function

  # verdict: Symbol of :pass, :reject, :flag, or :surface
  # results: Hash of { check_name => status_string }, e.g.
  #   { "honeypot" => "reject", "referer" => "pass", "turnstile" => "not_applied" }
  def record(form_id:, verdict:, results:)
    return unless defined?(NewRelic::Agent)

    increment_counters(verdict, results)
    record_custom_event(form_id, results)
  end

  # One counter per check outcome so we can chart how many submissions each
  # prevention method blocks (and how often it is applied), plus a total.
  def increment_counters(verdict, results)
    NewRelic::Agent.increment_metric("Custom/Spam/#{verdict}")
    results.each do |check, status|
      NewRelic::Agent.increment_metric("Custom/Spam/#{check}/#{status}")
    end
  end

  # One custom event per submission, with each check flattened to its own
  # attribute (e.g. honeypot: "reject", referer: "pass") so NRQL can FACET on
  # check pairs to answer the redundancy / co-occurrence question.
  def record_custom_event(form_id, results)
    NewRelic::Agent.record_custom_event(
      'SpamCheck',
      { form_id: form_id }.merge(results),
    )
  end
end
