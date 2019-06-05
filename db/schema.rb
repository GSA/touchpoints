# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_05_051407) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "containers", force: :cascade do |t|
    t.string "name"
    t.string "gtm_container_id"
    t.string "gtm_container_public_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "service_id", null: false
  end

  create_table "form_templates", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "instructions"
    t.text "disclaimer_text"
    t.string "kind"
    t.text "notes"
    t.string "status"
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
    t.text "question_text_01"
    t.text "question_text_02"
    t.text "question_text_03"
    t.text "question_text_04"
    t.text "question_text_05"
    t.text "question_text_06"
    t.text "question_text_07"
    t.text "question_text_08"
    t.text "question_text_09"
    t.text "question_text_10"
    t.text "question_text_11"
    t.text "question_text_12"
    t.text "question_text_13"
    t.text "question_text_14"
    t.text "question_text_15"
    t.text "question_text_16"
    t.text "question_text_17"
    t.text "question_text_18"
    t.text "question_text_19"
    t.text "question_text_20"
    t.integer "character_limit", default: 0
    t.string "whitelist_url", default: ""
    t.string "whitelist_test_url", default: ""
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

  create_table "pra_contacts", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "department"
    t.string "program"
    t.integer "organization_id"
    t.integer "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "programs", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "organization_id"
    t.string "service_manager"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "touchpoint_id", null: false
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
  end

  create_table "touchpoints", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enable_google_sheets", default: false
    t.integer "container_id"
    t.string "google_sheet_id"
    t.integer "form_id"
    t.text "purpose"
    t.integer "meaningful_response_size"
    t.text "behavior_change"
    t.string "notification_emails"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "omb_approval_number"
    t.date "expiration_date"
    t.integer "service_id"
    t.boolean "editable", default: true
  end

  create_table "triggers", force: :cascade do |t|
    t.integer "touchpoint_id"
    t.string "name"
    t.string "kind"
    t.string "fingerprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_services", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
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
    t.boolean "organization_manager", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
