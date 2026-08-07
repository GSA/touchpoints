# frozen_string_literal: true

module SpamChecks
  # Flags submissions whose referer is not on the form's allowlist, and is
  # neither the Touchpoints application itself nor the form's organization.
  #
  # Required context keys:
  #   :referer  — String referer to validate (may be nil/blank)
  #   :root_url — String root URL of the running application (may be nil)
  class Referer < Base
    # Persisted identifier written to submission.spam_determination["reasons"].
    CHECK_NAME = 'referer'
    LABEL = 'Unauthorized referer'

    # Key under which the invalid referer is stored in the Result context and
    # persisted to submission.spam_determination["context"][CHECK_NAME].
    CONTEXT_KEY = 'referer'

    # Rebuilds the description for a persisted result, naming the specific
    # referer that failed the check. Falls back to a placeholder when the
    # referer was not recorded (e.g. legacy determinations).
    def self.description(context = {})
      referer = context.is_a?(Hash) ? context[CONTEXT_KEY].presence : nil
      referer ||= '(no referer recorded)'

      "The response claimed to be submitted from #{referer}, which is not on this " \
        "form's allowlist. This can indicate spam, but it may also happen " \
        'when an embedded form is missing a domain from its allowlist.'
    end

    private

    def applicable?
      referer.present?
    end

    # Why flag on failure instead of reject?
    # Because some failures could be due to form misconfiguration,
    # specifically if the whitelist is incomplete for embedded forms.
    def evaluate
      is_allowed = allowlisted? ||
                   from_touchpoints? ||
                   from_form_organization?
      is_allowed ? :pass : :flag
    end

    def allowlisted?
      whitelist_prefixes.any? { |prefix| referer.start_with?(prefix) }
    end

    def from_touchpoints?
      root_url = context[:root_url]
      return false if root_url.blank?

      referer.start_with?(root_url)
    end

    def from_form_organization?
      org_url = submission.form.organization&.url
      return false if org_url.blank?

      referer.start_with?(org_url)
    end

    # Referer header
    def referer
      context[:referer]
    end

    # Persist the referer that was evaluated so the admin view can name it in
    # the flag description.
    def result_context
      { CONTEXT_KEY => referer }
    end

    def whitelist_prefixes
      whitelist_attributes = %i[
        whitelist_url
        whitelist_url_1
        whitelist_url_2
        whitelist_url_3
        whitelist_url_4
        whitelist_url_5
        whitelist_url_6
        whitelist_url_7
        whitelist_url_8
        whitelist_url_9
        whitelist_test_url
      ]

      whitelist_attributes.filter_map do |attr|
        value = submission.form.public_send(attr)
        value.presence
      end
    end
  end
end
