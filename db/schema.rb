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

ActiveRecord::Schema[7.2].define(version: 2025_02_14_194816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "barriers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "collections", comment: "Quarterly CX Data Collection", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.integer "organization_id"
    t.string "year"
    t.string "quarter"
    t.integer "user_id"
    t.string "integrity_hash"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reflection"
    t.string "rating"
    t.integer "service_provider_id"
    t.index ["organization_id"], name: "index_collections_on_organization_id"
    t.index ["service_provider_id"], name: "index_collections_on_service_provider_id"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "cx_action_plans", force: :cascade do |t|
    t.integer "service_provider_id"
    t.integer "year"
    t.text "delivered_current_year"
    t.text "to_deliver_next_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cx_collection_detail_uploads", force: :cascade do |t|
    t.integer "user_id"
    t.integer "cx_collection_detail_id"
    t.integer "size", comment: "file size of the s3 object"
    t.string "key", comment: "s3 path to the asset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.string "record_count"
    t.string "job_id"
  end

  create_table "cx_collection_details", force: :cascade do |t|
    t.integer "cx_collection_id"
    t.string "transaction_point"
    t.string "channel"
    t.integer "service_stage_id"
    t.integer "volume_of_customers"
    t.integer "volume_of_customers_provided_survey_opportunity"
    t.integer "volume_of_respondents"
    t.string "omb_control_number"
    t.string "federal_register_url"
    t.text "reflection_text"
    t.text "survey_type"
    t.text "survey_title"
    t.text "trust_question_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cx_collections", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.integer "organization_id"
    t.integer "service_provider_id"
    t.integer "service_id"
    t.string "service_type"
    t.string "digital_service_or_contact_center"
    t.string "url"
    t.string "fiscal_year"
    t.string "quarter"
    t.string "transaction_point"
    t.integer "service_stage_id"
    t.string "channel"
    t.string "survey_title"
    t.string "trust_question_text"
    t.string "likert_or_thumb_question"
    t.integer "number_of_interactions"
    t.string "number_of_people_offered_the_survey"
    t.string "aasm_state"
    t.string "rating"
    t.string "integrity_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
  end

  create_table "cx_responses", force: :cascade do |t|
    t.integer "cx_collection_detail_id"
    t.integer "cx_collection_detail_upload_id"
    t.string "question_1", comment: "thumbs up/down"
    t.string "positive_effectiveness"
    t.string "positive_ease"
    t.string "positive_efficiency"
    t.string "positive_transparency"
    t.string "positive_humanity"
    t.string "positive_employee"
    t.string "positive_other"
    t.string "negative_effectiveness"
    t.string "negative_ease"
    t.string "negative_efficiency"
    t.string "negative_transparency"
    t.string "negative_humanity"
    t.string "negative_employee"
    t.string "negative_other"
    t.string "question_4", comment: "open text"
    t.string "job_id", comment: "a unique ID assigned when a batch of responses is imported"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
  end

  create_table "digital_product_versions", force: :cascade do |t|
    t.bigint "digital_product_id"
    t.string "store_url"
    t.string "platform"
    t.string "version_number"
    t.date "publish_date"
    t.string "description"
    t.string "whats_new"
    t.string "screenshot_url"
    t.string "device"
    t.string "language"
    t.string "average_rating"
    t.integer "number_of_ratings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legacy_id"
    t.text "legacy_notes"
    t.index ["digital_product_id"], name: "index_digital_product_versions_on_digital_product_id"
  end

  create_table "digital_products", force: :cascade do |t|
    t.integer "user_id"
    t.string "service"
    t.string "url"
    t.string "code_repository_url"
    t.string "language"
    t.string "aasm_state"
    t.string "short_description"
    t.text "long_description"
    t.text "notes"
    t.string "tags"
    t.datetime "certified_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "legacy_id"
    t.text "legacy_notes"
    t.index ["aasm_state"], name: "index_digital_products_on_aasm_state"
  end

  create_table "digital_service_accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string "service"
    t.string "service_url"
    t.string "language"
    t.string "short_description"
    t.text "long_description"
    t.text "notes"
    t.string "tags"
    t.datetime "certified_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "aasm_state"
    t.integer "legacy_id"
    t.text "legacy_notes"
    t.index ["aasm_state"], name: "index_digital_service_accounts_on_aasm_state"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.string "object_type"
    t.string "object_uuid", null: false
    t.string "description", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "form_sections", force: :cascade do |t|
    t.integer "form_id"
    t.string "title"
    t.integer "position"
    t.integer "next_section_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["form_id"], name: "index_form_sections_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "instructions"
    t.string "disclaimer_text"
    t.string "kind"
    t.text "notes"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
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
    t.datetime "last_response_created_at", precision: nil
    t.boolean "ui_truncate_text_responses", default: true
    t.string "success_text_heading"
    t.string "notification_frequency", default: "instant"
    t.integer "service_id"
    t.integer "questions_count", default: 0
    t.boolean "verify_csrf", default: false
    t.string "submissions_tags", array: true
    t.string "whitelist_url_1"
    t.string "whitelist_url_2"
    t.string "whitelist_url_3"
    t.string "whitelist_url_4"
    t.string "whitelist_url_5"
    t.string "whitelist_url_6"
    t.string "whitelist_url_7"
    t.string "whitelist_url_8"
    t.string "whitelist_url_9"
    t.string "submission_tags", default: [], comment: "cache the form's submissions tags for reporting", array: true
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.datetime "archived_at"
    t.string "audience", default: "public", comment: "indicates whether a form is intended for a public or internal audience"
    t.string "short_uuid", limit: 8
    t.boolean "enforce_new_submission_validations", default: true
    t.integer "service_stage_id"
    t.boolean "legacy_link_feature_flag", default: false, comment: "when true, render fba-button as an A, otherwise render as BUTTON"
    t.index ["legacy_touchpoint_id"], name: "index_forms_on_legacy_touchpoint_id"
    t.index ["legacy_touchpoint_uuid"], name: "index_forms_on_legacy_touchpoint_uuid"
    t.index ["organization_id"], name: "index_forms_on_organization_id"
    t.index ["service_id"], name: "index_forms_on_service_id"
    t.index ["short_uuid"], name: "index_forms_on_short_uuid", unique: true
    t.index ["user_id"], name: "index_forms_on_user_id"
    t.index ["uuid"], name: "index_forms_on_uuid", unique: true
  end

  create_table "ivn_component_links", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ivn_components", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ivn_source_component_links", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ivn_sources", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "omb_cx_reporting_collections", comment: "A detailed record belonging to a Collection; a quarterly CX Data Collection", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "operational_metrics"
    t.integer "service_id"
    t.index ["collection_id"], name: "index_omb_cx_reporting_collections_on_collection_id"
    t.index ["service_id"], name: "index_omb_cx_reporting_collections_on_service_id"
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
    t.text "mission_statement"
    t.string "mission_statement_url"
    t.string "performance_url"
    t.string "strategic_plan_url"
    t.string "learning_agenda_url"
    t.boolean "cfo_act_agency", default: false
    t.integer "parent_id"
    t.boolean "form_approval_enabled", default: false, comment: "Indicate whether this organization requires a Submission and Approval process for forms"
  end

  create_table "organizations_roles", id: false, force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "role_id"
    t.index ["organization_id", "role_id"], name: "index_organizations_roles_on_organization_id_and_role_id"
    t.index ["organization_id"], name: "index_organizations_roles_on_organization_id"
    t.index ["role_id"], name: "index_organizations_roles_on_role_id"
  end

  create_table "personas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "tags", array: true
    t.integer "user_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tags"], name: "index_personas_on_tags", using: :gin
  end

  create_table "question_options", force: :cascade do |t|
    t.integer "question_id"
    t.string "text"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "value"
    t.boolean "other_option", default: false
    t.index ["question_id"], name: "index_question_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "form_id"
    t.string "text"
    t.string "question_type"
    t.string "answer_field"
    t.integer "position"
    t.boolean "is_required"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "form_section_id"
    t.integer "character_limit"
    t.string "placeholder_text"
    t.string "help_text"
    t.index ["form_id"], name: "index_questions_on_form_id"
    t.index ["form_section_id"], name: "index_questions_on_form_section_id"
  end

  create_table "registry_searches", force: :cascade do |t|
    t.string "agency"
    t.string "keywords"
    t.string "platform"
    t.string "status"
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "service_providers", comment: "A Service Provider, or HISP, as defined in OMB Circular A-11 Section 280", force: :cascade do |t|
    t.integer "organization_id"
    t.string "name"
    t.text "description"
    t.text "notes"
    t.string "slug"
    t.string "department"
    t.string "department_abbreviation"
    t.string "bureau"
    t.string "bureau_abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "new"
    t.boolean "inactive", default: true, null: false
    t.string "url"
    t.integer "cx_maturity_mapping_value", default: 0
    t.integer "services_count", default: 0
    t.integer "impact_mapping_value", default: 0
    t.string "portfolio_manager_email"
    t.integer "year_designated"
    t.index ["organization_id"], name: "index_service_providers_on_organization_id"
  end

  create_table "service_stage_barriers", force: :cascade do |t|
    t.integer "service_stage_id"
    t.integer "barrier_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "service_stages", comment: "A step or stage within a Service, as used in a Business Process Model. eg: start, middle, end", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "service_id"
    t.text "notes"
    t.integer "time"
    t.integer "position"
    t.integer "total_eligible_population"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "persona_id"
    t.index ["service_id"], name: "index_service_stages_on_service_id"
  end

  create_table "services", id: { comment: "Unique identifier for a Service" }, comment: "Services provided by an Agency, often by a Service Provider within an Agency", force: :cascade do |t|
    t.string "name", comment: "Name of the service"
    t.text "description", comment: "Description of the designated service"
    t.integer "organization_id", comment: "Unique number for each department. A department may contain several HISPs"
    t.text "notes", comment: "Field for HISP to provide additional notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "hisp", default: false, comment: "True or False - Is this Service considered a HISP service?"
    t.string "department", default: "", comment: "Abbreviation of department name"
    t.string "bureau", default: "", comment: "Name of the Bureau to which a service belongs"
    t.string "service_slug", default: "", comment: "a unique text string to identify the service"
    t.string "url", default: "", comment: "A website link to their service"
    t.integer "service_provider_id", comment: "Unique number for each Service Provider"
    t.integer "service_owner_id", comment: "ID of the User record for which a Service is owned or managed by"
    t.string "kind", comment: "Identifies the category of service: compliance, administrative, benefits, recreation, informational, data and research, and regulatory", array: true
    t.string "aasm_state", default: "created", comment: "State/status that a Service is in. eg: created, submitted, approved, verified, archived"
    t.text "non_digital_explanation", comment: "If applicable, explain why a service is not available via a digital channel"
    t.integer "service_stages_count", default: 0, comment: "Helper field that counts how many Service Stages this Service has"
    t.string "homepage_url", comment: "A primary website link to the service"
    t.string "budget_code", comment: "The budget code for this service"
    t.string "uii_code", comment: "The UII code for this service"
    t.boolean "transactional", default: false, comment: "True or False for whether the service is transactional"
    t.boolean "digital_service", default: false, comment: "Is this a digital service or not?"
    t.string "estimated_annual_volume_of_customers", default: "", comment: "Estimated volume of customers on an annual basis"
    t.string "channels", comment: "One or more channels where the service is delivered", array: true
    t.boolean "fully_digital_service", default: false, comment: "Is this a fully digital service or not?"
    t.text "barriers_to_fully_digital_service", comment: "If applicable, describe the barriers preventing this service from being a fully digital service"
    t.boolean "multi_agency_service", default: false, comment: "Do multiple agencies collaborate to provide this service?"
    t.text "multi_agency_explanation", comment: "If applicable, describe how multiple agencies collaborate to provide this service"
    t.string "other_service_type"
    t.string "customer_volume_explanation"
    t.text "resources_needed_to_provide_digital_service", comment: "If applicable, what resources are needed to provide this service digitally?"
    t.string "office", comment: "Text description for the office (below a Bureau)"
    t.boolean "designated_for_improvement_a11_280", default: false, comment: "Is this Service designated, per the OMB Circular A-11 Section 280"
    t.boolean "contact_center", default: false, comment: "True or False for whether the service involves a contact center and/or an interaction with a contact center"
    t.integer "year_designated"
    t.text "short_description"
    t.boolean "previously_reported", default: false
    t.integer "cx_collections_count", default: 0
    t.index ["organization_id"], name: "index_services_on_organization_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.string "hostname"
    t.string "tags", default: [], array: true
    t.integer "spam_score", default: 0
    t.text "query_string"
    t.boolean "spam", default: false
    t.boolean "archived", default: false
    t.boolean "deleted", default: false
    t.datetime "deleted_at"
    t.string "preview", default: ""
    t.index ["archived"], name: "index_submissions_on_archived"
    t.index ["created_at"], name: "index_submissions_on_created_at"
    t.index ["flagged"], name: "index_submissions_on_flagged"
    t.index ["form_id"], name: "index_submissions_on_form_id"
    t.index ["spam"], name: "index_submissions_on_spam"
    t.index ["uuid"], name: "index_submissions_on_uuid", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "form_id"
    t.string "role"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "form_id"], name: "index_user_roles_on_user_id_and_form_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "organization_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false
    t.string "provider"
    t.string "uid"
    t.boolean "inactive", default: false, null: false
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.string "api_key"
    t.datetime "api_key_updated_at", precision: nil
    t.boolean "organizational_website_manager", default: false
    t.boolean "performance_manager", default: false
    t.boolean "registry_manager", default: false
    t.boolean "service_manager", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "position_title"
    t.string "profile_photo"
    t.boolean "organizational_admin", default: false
    t.boolean "organizational_form_approver", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "websites", force: :cascade do |t|
    t.string "domain"
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
    t.boolean "uses_feedback"
    t.string "feedback_tool"
    t.string "sitemap_url"
    t.boolean "mobile_friendly"
    t.boolean "has_search"
    t.boolean "uses_tracking_cookies"
    t.boolean "has_authenticated_experience"
    t.string "authentication_tool"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "repository_url"
    t.string "hosting_platform"
    t.float "modernization_cost_2021"
    t.float "modernization_cost_2022"
    t.float "modernization_cost_2023"
    t.string "uswds_version"
    t.boolean "https"
    t.integer "service_id"
    t.integer "organization_id"
    t.string "backlog_tool", default: ""
    t.string "backlog_url", default: ""
    t.string "aasm_state"
    t.date "target_decommission_date"
    t.index ["aasm_state"], name: "index_websites_on_aasm_state"
    t.index ["organization_id"], name: "index_websites_on_organization_id"
    t.index ["service_id"], name: "index_websites_on_service_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
end
