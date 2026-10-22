# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bin/standalone-migrate' do
  let(:script_path) { File.expand_path('../../bin/standalone-migrate', __dir__) }
  let(:migration_context) { instance_double(ActiveRecord::MigrationContext, migrate: nil) }
  let(:migrations_path) { File.expand_path('../../db/migrate', __dir__) }

  around do |example|
    original_env = ENV.to_hash
    test_env = original_env.reject { |key, _| %w[DATABASE_URL RAILS_ENV RACK_ENV VERSION].include?(key) }
    ENV.replace(test_env)

    example.run
  ensure
    ENV.replace(original_env)
  end

  before do
    allow(ActiveRecord::Base).to receive(:logger=)
    allow(ActiveRecord::Base).to receive(:establish_connection)
    allow(ActiveRecord::MigrationContext).to receive(:new).and_return(migration_context)
  end

  def load_script
    load script_path
  end

  it 'requires DATABASE_URL' do
    expect { load_script }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end

    expect(ActiveRecord::Base).not_to have_received(:establish_connection)
    expect(migration_context).not_to have_received(:migrate)
  end

  it 'fails closed for an invalid VERSION before connecting to the database' do
    ENV['DATABASE_URL'] = 'postgresql://example.invalid/touchpoints_test'
    ENV['VERSION'] = 'not-a-version'

    expect { load_script }.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(1)
    end

    expect(ActiveRecord::Base).not_to have_received(:establish_connection)
    expect(migration_context).not_to have_received(:migrate)
  end

  it 'migrates to the latest version using DATABASE_URL' do
    ENV['DATABASE_URL'] = 'postgresql://example.invalid/touchpoints_test'
    ENV['RAILS_ENV'] = 'test'

    load_script

    expect(ActiveRecord::Base).to have_received(:establish_connection).with('postgresql://example.invalid/touchpoints_test')
    expect(ActiveRecord::MigrationContext).to have_received(:new).with(migrations_path)
    expect(migration_context).to have_received(:migrate).with(no_args)
  end

  it 'migrates to a validated target VERSION' do
    ENV['DATABASE_URL'] = 'postgresql://example.invalid/touchpoints_test'
    ENV['RAILS_ENV'] = 'test'
    ENV['VERSION'] = '20250101010101'

    load_script

    expect(migration_context).to have_received(:migrate).with(20250101010101)
  end
end
