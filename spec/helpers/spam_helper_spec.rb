require 'rails_helper'

RSpec.describe SpamHelper, type: :helper do
  describe "#spam_reason_label" do
    it "returns the check's label for a known reason" do
      expect(helper.spam_reason_label('honeypot')).to eq('Hidden field was filled in')
    end

    it "humanizes an unknown reason" do
      expect(helper.spam_reason_label('some_other_check')).to eq('Some other check')
    end
  end

  describe "#spam_reason_description" do
    it "returns the check's description for a known reason" do
      expect(helper.spam_reason_description('turnstile'))
        .to eq('The response did not pass the Cloudflare Turnstile bot-detection challenge.')
    end

    it "passes stored context through so the description can name specifics" do
      expect(helper.spam_reason_description('referer', 'referer' => 'https://evil.example/'))
        .to include('https://evil.example/')
    end

    it "tolerates a nil context" do
      expect(helper.spam_reason_description('referer', nil))
        .to include('(no referer recorded)')
    end

    it "returns nil for an unknown reason" do
      expect(helper.spam_reason_description('some_other_check')).to be_nil
    end
  end
end
