# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamChecks::Base do
  let(:submission) { Submission.new }

  describe '#call' do
    it 'returns :not_applied without calling #evaluate when not applicable' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'test_check')
        def applicable? = false
        def evaluate = raise('should not be called')
      end

      result = check_class.new(submission: submission).call
      expect(result.status).to eq(:not_applied)
    end

    it 'returns :reject when evaluate returns :reject' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'test_check')
        def evaluate = :reject
      end

      result = check_class.new(submission: submission).call
      expect(result.status).to eq(:reject)
      expect(result).to be_reject
    end

    it 'raises NotImplementedError when #evaluate is not overridden' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'test_check')
      end

      expect do
        check_class.new(submission: submission, context: {}).call
      end.to raise_error(NotImplementedError)
    end

    it 'defaults the result context to an empty hash' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'test_check')
        def evaluate = :pass
      end

      result = check_class.new(submission: submission).call
      expect(result.context).to eq({})
    end

    it 'exposes the context returned by #result_context' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'test_check')
        def evaluate = :flag
        def result_context = { 'detail' => 'value' }
      end

      result = check_class.new(submission: submission).call
      expect(result.context).to eq('detail' => 'value')
    end
  end

  describe '.check_name' do
    it 'returns the declared CHECK_NAME constant' do
      expect(SpamChecks::Honeypot.check_name).to eq('honeypot')
    end
  end

  describe '.label' do
    it 'returns the LABEL constant when set' do
      expect(SpamChecks::Honeypot.label).to eq('Hidden field was filled in')
    end

    it 'humanizes the check name when LABEL is unset' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'some_other_check')
      end

      expect(check_class.label).to eq('Some other check')
    end
  end

  describe '.description' do
    it 'returns the DESCRIPTION constant when set' do
      expect(SpamChecks::Turnstile.description)
        .to eq('The response did not pass the Cloudflare Turnstile bot-detection challenge.')
    end

    it 'ignores a supplied context by default' do
      expect(SpamChecks::Turnstile.description('anything' => 'here'))
        .to eq('The response did not pass the Cloudflare Turnstile bot-detection challenge.')
    end

    it 'returns nil when DESCRIPTION is unset' do
      check_class = Class.new(described_class) do
        const_set(:CHECK_NAME, 'some_other_check')
      end

      expect(check_class.description).to be_nil
    end
  end

  describe '.for' do
    it 'looks up a check class by its check name' do
      expect(described_class.for('referer')).to eq(SpamChecks::Referer)
    end

    it 'returns nil for an unknown check name' do
      expect(described_class.for('nope')).to be_nil
    end
  end

  describe 'CHECK_NAME contract' do
    it 'every registered check declares a CHECK_NAME' do
      described_class.checks.each do |check|
        expect { check.check_name }.not_to raise_error
        expect(check.check_name).to be_present
      end
    end

    it 'check names are unique across all registered checks' do
      names = described_class.checks.map(&:check_name)
      expect(names).to eq(names.uniq)
    end
  end
end
