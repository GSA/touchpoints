# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamChecks::Referer do
  def check(form:, context:)
    submission = FactoryBot.build_stubbed(:submission, form:)
    described_class.new(submission: submission, context: context).call
  end

  describe 'applicability' do
    it 'is not applied when no referer is provided' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: 'https://agency.gov/')
      result = check(
        form: form,
        context: { referer: nil, root_url: 'https://touchpoints.gov/' }
      )
      expect(result.status).to eq(:not_applied)
    end
  end

  describe 'allowlist' do
    it 'passes when the referer matches a form whitelist prefix' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: 'https://agency.gov/')
      result = check(
        form: form,
        context: { referer: 'https://agency.gov/feedback', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:pass)
    end

    it 'passes when the referer matches the whitelist_test_url' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: '', whitelist_test_url: 'https://staging.agency.gov/')
      result = check(
        form: form,
        context: { referer: 'https://staging.agency.gov/x', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:pass)
    end

    it 'ignores blank whitelist columns' do
      # whitelist_url / whitelist_test_url default to "" — a blank prefix must
      # not match every referer.
      form = FactoryBot.build_stubbed(:form, whitelist_url: '', whitelist_test_url: '')
      allow(form).to receive(:organization).and_return(nil)
      result = check(
        form: form,
        context: { referer: 'https://evil.example/', root_url: nil },
      )
      expect(result.status).to eq(:flag)
    end
  end

  describe 'Touchpoints application referer' do
    it 'passes when the referer starts with the application root_url' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: '')
      result = check(
        form: form,
        context: { referer: 'https://touchpoints.gov/some/page', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:pass)
    end

    it 'does not treat the referer as Touchpoints when root_url is nil' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: '')
      allow(form).to receive(:organization).and_return(nil)
      result = check(
        form: form,
        context: { referer: 'https://touchpoints.gov/some/page', root_url: nil },
      )
      expect(result.status).to eq(:flag)
    end
  end

  describe "form organization's site" do
    it 'passes when the referer starts with the organization url' do
      organization = FactoryBot.build_stubbed(:organization, url: 'https://org.gov')
      form = FactoryBot.build_stubbed(:form, organization: organization, whitelist_url: '')
      result = check(
        form: form,
        context: { referer: 'https://org.gov/page', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:pass)
    end

    it 'rejects (does not raise) when the organization is nil' do
      form = FactoryBot.build_stubbed(:form, whitelist_url: '')
      allow(form).to receive(:organization).and_return(nil)
      result = check(
        form: form,
        context: { referer: 'https://evil.example/', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:flag)
    end

    it 'rejects (does not raise) when the organization url is nil' do
      organization = FactoryBot.build_stubbed(:organization, url: nil)
      form = FactoryBot.build_stubbed(:form, organization: organization, whitelist_url: '')
      result = check(
        form: form,
        context: { referer: 'https://evil.example/', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:flag)
    end
  end

  describe 'flag' do
    it 'flags when the referer is not allowlisted, not Touchpoints, and not the org site' do
      organization = FactoryBot.build_stubbed(:organization, url: 'https://org.gov')
      form = FactoryBot.build_stubbed(:form, organization: organization, whitelist_url: 'https://agency.gov/')
      result = check(
        form: form,
        context: { referer: 'https://evil.example/', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.status).to eq(:flag)
    end

    it 'records the evaluated referer in the result context' do
      organization = FactoryBot.build_stubbed(:organization, url: 'https://org.gov')
      form = FactoryBot.build_stubbed(:form, organization: organization, whitelist_url: 'https://agency.gov/')
      result = check(
        form: form,
        context: { referer: 'https://evil.example/', root_url: 'https://touchpoints.gov/' },
      )
      expect(result.context).to eq('referer' => 'https://evil.example/')
    end
  end

  describe '.description' do
    it 'names the specific referer from the persisted context' do
      expect(described_class.description('referer' => 'https://evil.example/'))
        .to include('https://evil.example/')
    end

    it 'falls back to a placeholder when no referer was recorded' do
      expect(described_class.description({}))
        .to include('(no referer recorded)')
    end

    it 'falls back to a placeholder when the context is nil' do
      expect(described_class.description(nil))
        .to include('(no referer recorded)')
    end
  end
end
