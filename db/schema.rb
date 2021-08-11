# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_11_234411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "barriers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.integer "organization_id"
    t.string "year"
    t.string "quarter"
    t.integer "user_id"
    t.string "integrity_hash"
    t.string "aasm_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reflection"
    t.string "rating"
    t.integer "service_provider_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.string "object_type"
    t.string "object_id", null: false
    t.string "description", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "form_sections", force: :cascade do |t|
    t.integer "form_id"
    t.string "title"
    t.integer "position"
    t.integer "next_section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "instructions"
    t.string "disclaimer_text"
    t.string "kind"
    t.text "notes"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "whitelist_url", default: ""
    t.string "whitelist_test_url", default: ""
    t.boolean "display_header_logo", default: false
    t.text "success_text"
    t.string "modal_button_text"
    t.boolean "display_header_square_logo"
    t.boolean "early_submission", default: false
    t.integer "user_id"
    t.boolean "template", default: false
    t.string "uuid"
    t.integer "organization_id"
    t.string "omb_approval_number"
    t.date "expiration_date"
    t.string "medium"
    t.string "federal_register_url"
    t.integer "anticipated_delivery_count"
    t.string "service_name"
    t.text "data_submission_comment"
    t.string "survey_instrument_reference"
    t.string "agency_poc_email"
    t.string "agency_poc_name"
    t.string "department"
    t.string "bureau"
    t.string "notification_emails"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "aasm_state"
    t.string "delivery_method"
    t.string "element_selector"
    t.integer "survey_form_activations", default: 0
    t.integer "legacy_touchpoint_id"
    t.string "legacy_touchpoint_uuid"
    t.boolean "load_css", default: true
    t.string "logo"
    t.string "occasion"
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.integer "response_count", default: 0
    t.datetime "last_response_created_at"
    t.boolean "ui_truncate_text_responses", default: true
    t.string "success_text_heading"
    t.string "notification_frequency", default: "instant"
    t.index ["legacy_touchpoint_id"], name: "index_forms_on_legacy_touchpoint_id"
    t.index ["legacy_touchpoint_uuid"], name: "index_forms_on_legacy_touchpoint_uuid"
    t.index ["uuid"], name: "index_forms_on_uuid"
  end

  create_table "milestones", force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.text "description"
    t.date "due_date"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "omb_cx_reporting_collections", force: :cascade do |t|
    t.integer "collection_id"
    t.string "service_provided"
    t.text "transaction_point"
    t.string "channel"
    t.integer "volume_of_customers", default: 0
    t.integer "volume_of_customers_provided_survey_opportunity", default: 0
    t.integer "volume_of_respondents", default: 0
    t.string "omb_control_number"
    t.string "federal_register_url"
    t.string "q1_text"
    t.integer "q1_1", default: 0
    t.integer "q1_2", default: 0
    t.integer "q1_3", default: 0
    t.integer "q1_4", default: 0
    t.integer "q1_5", default: 0
    t.string "q2_text"
    t.integer "q2_1", default: 0
    t.integer "q2_2", default: 0
    t.integer "q2_3", default: 0
    t.integer "q2_4", default: 0
    t.integer "q2_5", default: 0
    t.string "q3_text"
    t.integer "q3_1", default: 0
    t.integer "q3_2", default: 0
    t.integer "q3_3", default: 0
    t.integer "q3_4", default: 0
    t.integer "q3_5", default: 0
    t.string "q4_text"
    t.integer "q4_1", default: 0
    t.integer "q4_2", default: 0
    t.integer "q4_3", default: 0
    t.integer "q4_4", default: 0
    t.integer "q4_5", default: 0
    t.string "q5_text"
    t.integer "q5_1", default: 0
    t.integer "q5_2", default: 0
    t.integer "q5_3", default: 0
    t.integer "q5_4", default: 0
    t.integer "q5_5", default: 0
    t.string "q6_text"
    t.integer "q6_1", default: 0
    t.integer "q6_2", default: 0
    t.integer "q6_3", default: 0
    t.integer "q6_4", default: 0
    t.integer "q6_5", default: 0
    t.string "q7_text"
    t.integer "q7_1", default: 0
    t.integer "q7_2", default: 0
    t.integer "q7_3", default: 0
    t.integer "q7_4", default: 0
    t.integer "q7_5", default: 0
    t.string "q8_text"
    t.integer "q8_1", default: 0
    t.integer "q8_2", default: 0
    t.integer "q8_3", default: 0
    t.integer "q8_4", default: 0
    t.integer "q8_5", default: 0
    t.string "q9_text"
    t.integer "q9_1", default: 0
    t.integer "q9_2", default: 0
    t.integer "q9_3", default: 0
    t.integer "q9_4", default: 0
    t.integer "q9_5", default: 0
    t.string "q10_text"
    t.integer "q10_1", default: 0
    t.integer "q10_2", default: 0
    t.integer "q10_3", default: 0
    t.integer "q10_4", default: 0
    t.integer "q10_5", default: 0
    t.string "q11_text"
    t.integer "q11_1", default: 0
    t.integer "q11_2", default: 0
    t.integer "q11_3", default: 0
    t.integer "q11_4", default: 0
    t.integer "q11_5", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "operational_metrics"
    t.integer "service_id"
    t.index ["collection_id"], name: "index_omb_cx_reporting_collections_on_collection_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.string "abbreviation"
    t.text "notes"
    t.integer "external_id"
    t.string "domain"
    t.string "logo"
    t.boolean "enable_ip_address", default: true
    t.string "digital_analytics_path"
  end

  create_table "question_options", force: :cascade do |t|
    t.integer "question_id"
    t.string "text"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "form_id"
    t.string "text"
    t.string "question_type"
    t.string "answer_field"
    t.integer "position"
    t.boolean "is_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "form_section_id"
    t.integer "character_limit"
    t.string "placeholder_text"
    t.string "help_text"
  end

  create_table "service_providers", force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.text "description"
    t.text "notes"
    t.string "slug"
    t.string "department"
    t.string "department_abbreviation"
    t.string "bureau"
    t.string "bureau_abbreviation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "new"
  end

  create_table "service_stage_barriers", force: :cascade do |t|
    t.integer "service_stage_id"
    t.integer "barrier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_stages", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "service_id"
    t.text "notes"
    t.integer "time"
    t.integer "total_eligible_population"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "organization_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hisp", default: false
    t.string "department", default: ""
    t.string "bureau", default: ""
    t.string "bureau_abbreviation", default: ""
    t.string "service_abbreviation", default: ""
    t.string "service_slug", default: ""
    t.string "url", default: ""
    t.integer "service_provider_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "referer"
    t.string "page"
    t.string "user_agent"
    t.text "answer_01"
    t.text "answer_02"
    t.text "answer_03"
    t.text "answer_04"
    t.text "answer_05"
    t.text "answer_06"
    t.text "answer_07"
    t.text "answer_08"
    t.text "answer_09"
    t.text "answer_10"
    t.text "answer_11"
    t.text "answer_12"
    t.text "answer_13"
    t.text "answer_14"
    t.text "answer_15"
    t.text "answer_16"
    t.text "answer_17"
    t.text "answer_18"
    t.text "answer_19"
    t.text "answer_20"
    t.string "ip_address"
    t.string "location_code"
    t.boolean "flagged", default: false
    t.string "language"
    t.integer "form_id"
    t.string "uuid"
    t.string "aasm_state", default: "received"
    t.boolean "archived", default: false
    t.index ["uuid"], name: "index_submissions_on_uuid", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "form_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "organization_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "provider"
    t.string "uid"
    t.boolean "inactive"
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.string "api_key"
    t.datetime "api_key_updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.string "domain"
    t.string "parent_domain"
    t.string "office"
    t.integer "office_id"
    t.string "sub_office"
    t.integer "suboffice_id"
    t.string "contact_email"
    t.string "site_owner_email"
    t.string "production_status"
    t.string "type_of_site"
    t.string "digital_brand_category"
    t.string "redirects_to"
    t.string "status_code"
    t.string "cms_platform"
    t.string "required_by_law_or_policy"
    t.boolean "has_dap"
    t.string "dap_gtm_code"
    t.string "cost_estimator_url"
    t.string "modernization_plan_url"
    t.float "annual_baseline_cost"
    t.float "modernization_cost"
    t.string "analytics_url"
    t.integer "current_uswds_score"
    t.boolean "uses_feedback"
    t.string "feedback_tool"
    t.string "sitemap_url"
    t.boolean "mobile_friendly"
    t.boolean "has_search"
    t.boolean "uses_tracking_cookies"
    t.boolean "has_authenticated_experience"
    t.string "authentication_tool"
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "repository_url"
    t.string "hosting_platform"
    t.float "modernization_cost_2021"
    t.float "modernization_cost_2022"
    t.float "modernization_cost_2023"
  end

end
