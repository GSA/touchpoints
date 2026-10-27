# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormCache, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { FactoryBot.create(:organization) }
  let(:form) { FactoryBot.create(:form, organization:) }

  # Retain entries so both object and widget cache examples exercise real hits.
  around do |example|
    original_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_store
  end

  describe 'validate cache fetch' do
    context 'when storing a touchpoint' do
      it 'caches a touchpoint' do
        cached_form = described_class.fetch(form.short_uuid)
        expect(cached_form.id).to eq(form.id)
      end
    end

    context 'when invalidating a touchpoint' do
      it 'removes a form from cache' do
        described_class.fetch(form.short_uuid)
        expect { described_class.invalidate(form.short_uuid) }
          .to change { Rails.cache.exist?("namespace:form-#{form.short_uuid}") }.from(true).to(false)
      end
    end
  end

  describe '.fetch_widget_js' do
    it 'returns the rendered output on a miss' do
      expect(described_class.fetch_widget_js(form:) { 'rendered' }).to eq('rendered')
    end

    it 'serves the cached copy without rendering again' do
      described_class.fetch_widget_js(form:) { 'rendered' }
      expect(described_class.fetch_widget_js(form:) { raise 'Unexpected render' }).to eq('rendered')
    end

    it 'caches each locale separately' do
      described_class.fetch_widget_js(form:, locale: :en) { 'english' }
      described_class.fetch_widget_js(form:, locale: :es) { 'spanish' }
      outputs = %i[en es].map { |locale| described_class.fetch_widget_js(form:, locale:) { raise 'Unexpected render' } }
      expect(outputs).to eq(%w[english spanish])
    end

    context 'when CSRF is enabled' do
      before { form.update!(verify_csrf: true) }

      it 'renders on every call' do
        calls = 0
        2.times { described_class.fetch_widget_js(form:) { calls += 1 } }
        expect(calls).to eq(2)
      end

      it 'does not store session-specific output' do
        described_class.fetch_widget_js(form:) { 'session-specific output' }
        expect(Rails.cache.read(described_class.widget_js_key(form.short_uuid, I18n.locale))).to be_nil
      end
    end

    it 'renders without caching when the form is missing' do
      expect(described_class.fetch_widget_js(form: nil) { 'rendered' }).to eq('rendered')
    end

    it 'serves freshly rendered JS after the form is invalidated' do
      described_class.fetch_widget_js(form:) { 'original' }
      described_class.invalidate(form.short_uuid)

      expect(described_class.fetch_widget_js(form:) { 'updated' }).to eq('updated')
    end

    it 'invalidates every available locale' do
      I18n.available_locales.each { |locale| described_class.fetch_widget_js(form:, locale:) { "original-#{locale}" } }
      described_class.invalidate(form.short_uuid)
      entries = I18n.available_locales.map { |locale| Rails.cache.read(described_class.widget_js_key(form.short_uuid, locale)) }
      expect(entries).to all(be_nil)
    end

    it 'does not let an in-flight render replace output after invalidation' do
      described_class.fetch_widget_js(form:) do
        described_class.invalidate(form.short_uuid)
        'old in-flight output'
      end

      expect(described_class.fetch_widget_js(form:) { 'current output' }).to eq('current output')
    end

    it 'reloads stale form instances before rendering a cache miss' do
      stale_form = Form.find(form.id)
      form.update!(title: 'Updated title')
      described_class.invalidate(form.short_uuid)

      expect(described_class.fetch_widget_js(form: stale_form) { stale_form.title }).to eq('Updated title')
    end

    it 'does not store output when CSRF is enabled after the initial lookup' do
      stale_form = Form.find(form.id)
      form.update!(verify_csrf: true)

      described_class.fetch_widget_js(form: stale_form) { 'session-specific output' }

      expect(Rails.cache.read(described_class.widget_js_key(form.short_uuid, I18n.locale))).to be_nil
    end

    it 'does not reuse a cache entry for another form' do
      other_form = FactoryBot.create(:form, organization:)
      described_class.fetch_widget_js(form:) { 'first form' }

      expect(described_class.fetch_widget_js(form: other_form) { 'second form' }).to eq('second form')
    end

    context 'when rendering fails' do
      def failed_render
        described_class.fetch_widget_js(form:) { raise 'Render failed' }
      end

      it 'propagates the rendering error' do
        expect { failed_render }.to raise_error('Render failed')
      end

      it 'renders again after a failure', :aggregate_failures do
        expect { failed_render }.to raise_error('Render failed')
        expect(described_class.fetch_widget_js(form:) { 'recovered' }).to eq('recovered')
      end
    end

    it 'expires rendered output after one hour' do
      described_class.fetch_widget_js(form:) { 'original' }

      travel 61.minutes do
        expect(described_class.fetch_widget_js(form:) { 'refreshed' }).to eq('refreshed')
      end
    end

    it 'keys on the widget template digest so a deploy cannot serve stale JS' do
      described_class.fetch_widget_js(form:) { 'original' }

      allow(described_class).to receive(:widget_template_digest).and_return('newdigest123')

      expect(described_class.fetch_widget_js(form:) { 'rebuilt' }).to eq('rebuilt')
    end
  end

  describe '.widget_template_digest' do
    context 'when running in development' do
      let(:cache_class) { Class.new(described_class) }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(ENV).to receive(:fetch).and_call_original
        allow(cache_class).to receive(:compute_widget_template_digest).and_return('first', 'updated')
      end

      it 'detects source changes when the opt-in flag is absent' do
        allow(ENV).to receive(:fetch).with('WIDGET_CACHE_MEMOIZE_DIGEST', nil).and_return(nil)
        digests = Array.new(2) { cache_class.widget_template_digest }
        expect(digests).to eq(%w[first updated])
      end

      it 'reuses the digest when explicitly enabled for load tests' do
        allow(ENV).to receive(:fetch).with('WIDGET_CACHE_MEMOIZE_DIGEST', nil).and_return('true')
        digests = Array.new(2) { cache_class.widget_template_digest }
        expect(digests).to eq(%w[first first])
      end

      it 'computes the digest only once when enabled' do
        allow(ENV).to receive(:fetch).with('WIDGET_CACHE_MEMOIZE_DIGEST', nil).and_return('true')
        2.times { cache_class.widget_template_digest }
        expect(cache_class).to have_received(:compute_widget_template_digest).once
      end

      it 'detects source changes when the flag is false' do
        allow(ENV).to receive(:fetch).with('WIDGET_CACHE_MEMOIZE_DIGEST', nil).and_return('false')
        digests = Array.new(2) { cache_class.widget_template_digest }
        expect(digests).to eq(%w[first updated])
      end
    end

    it 'is stable across calls' do
      original = described_class.widget_template_digest
      expect(described_class.widget_template_digest).to eq(original)
    end

    it 'changes when runtime widget configuration changes' do
      original = described_class.compute_widget_template_digest
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('TURNSTILE_SITE_KEY', nil).and_return('different-public-site-key')

      expect(described_class.compute_widget_template_digest).not_to eq(original)
    end
  end
end
