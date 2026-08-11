# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamChecks::Turnstile do

  def check(form:, context:)
    submission = FactoryBot.build_stubbed(:submission, form:)
    SpamChecks::Turnstile.new(submission: submission, context: context).call
  end

  it 'is not applied when the form does not have Turnstile enabled' do
    form = FactoryBot.build_stubbed(:form, enable_turnstile: false)
    result = check(form: form, context: { remote_ip: '1.2.3.4' })

    expect(result.status).to eq(:not_applied)
  end

  context 'when Turnstile is enabled' do
    let(:form) { FactoryBot.build_stubbed(:form, enable_turnstile: true) }

    it 'passes when the verifier confirms the token' do
      verifier = double(verify: :pass)
      result = check(
        form: form,
        context: { remote_ip: '1.2.3.4', verifier: verifier },
      )

      expect(result.status).to eq(:pass)
    end

    it 'surfaces when the verifier asks the user to try again' do
      verifier = double(verify: :surface)
      result = check(
        form: form,
        context: { remote_ip: '1.2.3.4', verifier: verifier },
      )

      expect(result.status).to eq(:surface)
    end

    it 'passes the token and remote_ip from the context to the verifier' do
      verifier = double
      expect(verifier).to receive(:verify).with(token: 'the-token', remote_ip: '1.2.3.4').and_return(:pass)

      check(
        form: form,
        context: { remote_ip: '1.2.3.4', cf_turnstile_response: 'the-token', verifier: verifier },
      )
    end
  end
end

RSpec.describe SpamChecks::TurnstileVerifier do
  describe '.verify' do
    def stub_cloudflare(body)
      response = instance_double(Net::HTTPResponse, body: body)
      allow(Net::HTTP).to receive(:post_form).and_return(response)
    end

    it 'surfaces without making a request when the token is blank' do
      expect(Net::HTTP).not_to receive(:post_form)
      expect(described_class.verify(token: '', remote_ip: '1.2.3.4')).to eq(:surface)
    end

    it 'surfaces without making a request when the token is nil' do
      expect(Net::HTTP).not_to receive(:post_form)
      expect(described_class.verify(token: nil, remote_ip: '1.2.3.4')).to eq(:surface)
    end

    it 'returns :pass when Cloudflare reports success' do
      stub_cloudflare('{"success":true}')

      expect(described_class.verify(token: 'good', remote_ip: '1.2.3.4')).to eq(:pass)
    end

    it 'fails open (:pass) when the secret key is missing' do
      stub_cloudflare('{"success":false,"error-codes":["missing-input-secret"]}')

      expect(described_class.verify(token: 'good', remote_ip: '1.2.3.4')).to eq(:pass)
    end

    it 'fails open (:pass) when the secret key is invalid' do
      stub_cloudflare('{"success":false,"error-codes":["invalid-input-secret"]}')

      expect(described_class.verify(token: 'good', remote_ip: '1.2.3.4')).to eq(:pass)
    end

    it 'surfaces when the token is a timeout or duplicate' do
      stub_cloudflare('{"success":false,"error-codes":["timeout-or-duplicate"]}')

      expect(described_class.verify(token: 'stale', remote_ip: '1.2.3.4')).to eq(:surface)
    end

    it 'surfaces when the token response is invalid' do
      stub_cloudflare('{"success":false,"error-codes":["invalid-input-response"]}')

      expect(described_class.verify(token: 'bad', remote_ip: '1.2.3.4')).to eq(:surface)
    end

    it 'fails open (:pass) on any other Cloudflare error' do
      stub_cloudflare('{"success":false,"error-codes":["internal-error"]}')

      expect(described_class.verify(token: 'good', remote_ip: '1.2.3.4')).to eq(:pass)
    end

    it 'fails open (:pass) when the request raises an error' do
      allow(Net::HTTP).to receive(:post_form).and_raise(StandardError)

      expect(described_class.verify(token: 'good', remote_ip: '1.2.3.4')).to eq(:pass)
    end
  end
end
