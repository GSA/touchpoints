# frozen_string_literal: true

require 'net/http'
require 'json'

module SpamChecks
  # Verifies a Cloudflare Turnstile token, treating a failed verification as
  # spam. Only applicable when the form has Turnstile enabled.
  #
  # The actual HTTP call is delegated to a `verifier` collaborator so this
  # check can be unit-tested without network access. The verifier must respond
  # to #verify(token:, remote_ip:) and return one of :pass, :reject, :flag, or
  # :surface (maybe-bot-but-user-fixable — prompt the user to try again).
  #
  # Required context keys:
  #   :cf_turnstile_response — String token from the client (may be nil/blank)
  #   :remote_ip             — String remote IP of the submitter
  class Turnstile < Base
    # Persisted identifier written to submission.spam_determination["reasons"].
    CHECK_NAME = 'turnstile'
    LABEL = 'Failed bot-detection challenge'
    DESCRIPTION = 'The response did not pass the Cloudflare Turnstile ' \
                  'bot-detection challenge.'

    private

    def applicable?
      submission.form.enable_turnstile?
    end

    def evaluate
      verifier.verify(token: context[:cf_turnstile_response], remote_ip: context[:remote_ip])
    end

    def verifier
      context.fetch(:verifier, TurnstileVerifier)
    end
  end

  # Thin wrapper around the Cloudflare Turnstile siteverify endpoint.
  module TurnstileVerifier
    SITEVERIFY_URI = URI('https://challenges.cloudflare.com/turnstile/v0/siteverify')

    def self.verify(token:, remote_ip:)
      # Might be a bot but fixable by user so give them a chance to fix
      return :surface if token.blank?

      response = Net::HTTP.post_form(
        SITEVERIFY_URI,
        {
          'secret' => ENV.fetch('TURNSTILE_SECRET_KEY', nil),
          'response' => token,
          'remoteip' => remote_ip,
        },
      )

      result = JSON.parse(response.body)
      return :pass if result['success'] == true

      if result['error-codes'].intersect?(%w[missing-input-secret invalid-input-secret])
        # Don't enforce Turnstile if Touchpoints is misconfigured
        Rails.logger.error 'Turnstile secret key is misconfigured'
        :pass
      elsif result['error-codes'].intersect?(%w[timeout-or-duplicate invalid-input-response])
        # Might be a bot but fixable by user so give them a chance to fix
        :surface
      else
        # Any other errors suggest Turnstile is having problems, fail open
        Rails.logger.warn "Turnstile verification returned failure with error codes #{result['error-codes'].join(', ')}"
        :pass
      end
    rescue StandardError => e
      Rails.logger.warn "Turnstile verification call failed with message: #{e.message}"
      :pass
    end
  end
end
