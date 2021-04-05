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

ActiveRecord::Schema.define(version: 2021_04_01_215215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "barriers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "hisp"
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
    t.index ["legacy_touchpoint_id"], name: "index_forms_on_legacy_touchpoint_id"
    t.index ["legacy_touchpoint_uuid"], name: "index_forms_on_legacy_touchpoint_uuid"
    t.index ["uuid"], name: "index_forms_on_uuid"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.string "abbreviation"
    t.text "notes"
    t.integer "external_id"
    t.string "domain"
    t.string "logo"
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
    t.integer "total_eligble_population"
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

end
