# frozen_string_literal: true

module SpamChecks
  # Flags submissions where the hidden honeypot field (fba_directive) was
  # filled in. Legitimate users never see or populate this field, so any
  # value indicates an automated submission.
  #
  # Required context keys: None
  class Honeypot < Base
    # Persisted identifier written to submission.spam_determination["reasons"].
    CHECK_NAME = 'honeypot'
    LABEL = 'Hidden field was filled in'
    DESCRIPTION = 'A hidden field that real people never see was filled in. ' \
                  'This almost always indicates an automated (bot) submission.'

    private

    def evaluate
      submission.fba_directive.present? ? :reject : :pass
    end
  end
end
