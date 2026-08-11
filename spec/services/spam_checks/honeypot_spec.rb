# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamChecks::Honeypot do
  def check(submission)
    SpamChecks::Honeypot.new(submission: submission).call
  end

  it 'rejects when the honeypot field (fba_directive) is filled in' do
    submission = Submission.new
    submission.fba_directive = 'i am a bot'

    expect(check(submission).status).to eq(:reject)
  end

  it 'passes when the honeypot field is blank' do
    submission = Submission.new
    submission.fba_directive = nil

    expect(check(submission).status).to eq(:pass)
  end
end
