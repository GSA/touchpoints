# frozen_string_literal: true

# Tables whose rows may be serialized into a captured OpenAPI example. Listed
# explicitly (rather than resetting every sequence in the schema) so the reset
# is cheap and the intent is auditable. Keep in sync with the models built by
# the :documentation factory traits used in spec/requests/api/v1.
RSWAG_SEQUENCE_TABLES = %w[
  organizations
  users
  user_roles
  service_providers
  services
  cx_collections
  cx_collection_details
  cx_collection_detail_uploads
  cx_responses
  forms
  form_sections
  questions
  question_options
  submissions
  websites
  taggings
  tags
].freeze

# Instant that all timestamps captured into the generated OpenAPI examples are
# pinned to. Any fixed UTC time works; this one is arbitrary but stable.
RSWAG_FROZEN_TIME = Time.utc(2026, 1, 1, 0, 0, 0).freeze

# Value pinned into ENV['API_GATEWAY_BASE_URL'] while the documentation examples
# run. ApiController#api_gateway_url reads this env var at request time, and
# because these specs simulate gateway-originated requests (from_api_gateway? is
# stubbed true via simulate_api_gateway_request), the resulting URL is captured
# into the generated openapi.yml. Pinning it here — rather than relying on a
# shell export at swaggerize time — guarantees the same value locally and in the
# CI sync-check, so the committed spec cannot drift based on the caller's env.
RSWAG_API_GATEWAY_BASE_URL = 'https://api.gsa.gov/analytics/touchpoints'

# Shared context for rswag request specs that capture response bodies as
# OpenAPI documentation examples (see TouchpointsSpecHelpers#capture_example).
#
# This context makes two classes of database-assigned values deterministic so
# the generated public/api/v1/openapi.yml stays byte-stable across runs (the CI
# "OpenAPI spec is up to date" sync-check fails on any drift):
#
# 1. Identifiers (primary keys and `*_id` foreign keys)
# ----------------------------------------------------
# The captured response bodies embed real ids that come from Postgres identity
# sequences. The suite uses DatabaseCleaner's :transaction strategy per example
# (spec/rails_helper.rb), which rolls back the *rows* created by each example
# but does NOT roll back the underlying sequence increments — sequence values
# are non-transactional in Postgres. As a result the id assigned to, say, the
# first organization in a given example depends on how many records every
# earlier example created. Add, remove, or reorder an example (or enable random
# ordering) and the ids in the regenerated spec shift.
#
# Fix: before each example, restart the identity sequence of every table whose
# records can appear in a captured example back to 1. Because DatabaseCleaner
# has already cleared the rows (its :transaction strategy starts in a
# before(:each) hook, and the suite truncates before(:suite)), restarting the
# sequences means each example builds its fixtures from the same id base. The
# captured ids are therefore deterministic across runs and independent of test
# order.
#
# 2. Timestamps (created_at / updated_at)
# ---------------------------------------
# Hard-coding created_at/updated_at in the factories only controls the value at
# the initial INSERT. If a model has an after_create / after_save / after_commit
# callback that re-saves the record, touches an association, or calls #touch,
# Rails' ActiveRecord::Timestamp rewrites updated_at to Time.current — clobbering
# the curated value and producing a timestamp that drifts every run.
#
# Fix: freeze the clock to RSWAG_FROZEN_TIME for the duration of each example via
# travel_to. Every timestamp Rails writes — initial insert, callback re-saves,
# association touches — then resolves to the same fixed instant, so factories no
# longer need to set created_at/updated_at at all. (Note: created_at and
# updated_at therefore collapse to the same value.)
#
# Usage
# -----
#   RSpec.describe '/v1/services', type: :request do
#     include_context 'rswag deterministic examples'
#     ...
#   end
RSpec.shared_context 'rswag deterministic examples' do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    original_api_gateway_base_url = ENV['API_GATEWAY_BASE_URL']
    ENV['API_GATEWAY_BASE_URL'] = RSWAG_API_GATEWAY_BASE_URL
    travel_to(RSWAG_FROZEN_TIME) { example.run }
  ensure
    ENV['API_GATEWAY_BASE_URL'] = original_api_gateway_base_url
  end

  before do
    connection = ActiveRecord::Base.connection

    RSWAG_SEQUENCE_TABLES.each do |table|
      # Skip tables not present in this schema rather than failing hard, so the
      # list above can be a superset and the context stays robust to schema
      # changes.
      next unless connection.data_source_exists?(table)

      # reset_pk_sequence! sets the sequence so the next inserted row gets id 1
      # (for an empty table). DatabaseCleaner has already emptied the table for
      # this example, so this gives every example the same id starting point.
      connection.reset_pk_sequence!(table)
    end
  end
end
