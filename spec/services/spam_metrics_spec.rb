# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamMetrics do
  let(:results) do
    { 'honeypot' => 'reject', 'referer' => 'pass', 'turnstile' => 'not_applied' }
  end

  describe '.record' do
    context 'when NewRelic is available' do
      before do
        stub_const('NewRelic::Agent', class_double('NewRelic::Agent'))
        allow(NewRelic::Agent).to receive(:increment_metric)
        allow(NewRelic::Agent).to receive(:record_custom_event)
      end

      it 'increments one counter per check outcome plus a total' do
        described_class.record(form_id: 42, verdict: :reject, results: results)

        expect(NewRelic::Agent).to have_received(:increment_metric).with('Custom/Spam/honeypot/reject')
        expect(NewRelic::Agent).to have_received(:increment_metric).with('Custom/Spam/referer/pass')
        expect(NewRelic::Agent).to have_received(:increment_metric).with('Custom/Spam/turnstile/not_applied')
        expect(NewRelic::Agent).to have_received(:increment_metric).with('Custom/Spam/reject')
      end

      it 'records a SpamCheck custom event with each check flattened to an attribute' do
        described_class.record(form_id: 42, verdict: :reject, results: results)

        expect(NewRelic::Agent).to have_received(:record_custom_event).with(
          'SpamCheck',
          { form_id: 42, 'honeypot' => 'reject', 'referer' => 'pass', 'turnstile' => 'not_applied' }
        )
      end
    end

    context 'when NewRelic is not defined' do
      it 'does not raise' do
        hide_const('NewRelic::Agent') if defined?(NewRelic::Agent)
        expect { described_class.record(form_id: 42, verdict: :reject, results: results) }.not_to raise_error
      end
    end
  end
end
