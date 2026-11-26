# frozen_string_literal: true

require 'rails_helper'
require 'tmpdir'

RSpec.describe LogoUploader do
  around do |example|
    Dir.mktmpdir('logo-uploader-spec') do |directory|
      # Processing is globally disabled in test; enable it only for this subclass.
      uploader_class = Class.new(described_class)
      uploader_class.root = directory
      @uploader = uploader_class.new(Form.new, :logo)
      @uploader.enable_processing = true
      @uploader.versions.each_value do |version|
        version.enable_processing = true
      end
      example.run
    end
  end

  it 'generates each logo version using real image processing' do
    File.open(Rails.root.join('spec/fixtures/files/touchpoints-banner.png')) do |file|
      @uploader.cache!(file)
    end

    aggregate_failures do
      expect(MiniMagick::Image.open(@uploader.thumb.path).dimensions).to eq([96, 96])
      expect(MiniMagick::Image.open(@uploader.card.path).width).to eq(360)
      expect(MiniMagick::Image.open(@uploader.tag.path).dimensions).to eq([342, 80])
      expect(MiniMagick::Image.open(@uploader.logo_square.path).dimensions).to eq([80, 80])
    end
  end

  it 'rejects unsupported file extensions' do
    File.open(Rails.root.join('spec/fixtures/files/test.txt')) do |file|
      expect { @uploader.cache!(file) }.to raise_error(CarrierWave::IntegrityError)
    end
  end

  it 'rejects invalid image content with an allowed extension' do
    Tempfile.create(['invalid-logo', '.png']) do |file|
      file.write('not an image')
      file.rewind

      expect { @uploader.cache!(file) }.to raise_error(CarrierWave::ProcessingError)
    end
  end
end
