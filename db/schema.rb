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

ActiveRecord::Schema[7.0].define(version: 2026_03_29_132127) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "job_matches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.integer "fit_score", default: 0, null: false
    t.text "fit_summary"
    t.text "skills_matched", default: [], array: true
    t.text "skills_missing", default: [], array: true
    t.jsonb "score_breakdown", default: {}
    t.text "explanation"
    t.datetime "scored_at"
    t.boolean "is_seen", default: false, null: false
    t.boolean "is_applied", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_saved", default: false, null: false
    t.index ["job_id"], name: "index_job_matches_on_job_id"
    t.index ["score_breakdown"], name: "index_job_matches_on_score_breakdown", using: :gin
    t.index ["user_id", "fit_score"], name: "index_job_matches_on_user_id_and_fit_score"
    t.index ["user_id", "is_saved"], name: "index_job_matches_on_user_id_and_is_saved"
    t.index ["user_id", "job_id"], name: "index_job_matches_on_user_id_and_job_id", unique: true
    t.index ["user_id"], name: "index_job_matches_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "source", null: false
    t.string "title", null: false
    t.string "company_name", null: false
    t.string "company_logo_url"
    t.string "location", default: "Remote"
    t.string "job_type", default: "full_time"
    t.string "category"
    t.text "description"
    t.text "required_skills", default: [], array: true
    t.integer "salary_min"
    t.integer "salary_max"
    t.string "salary_currency", default: "USD"
    t.string "salary_display"
    t.string "apply_url"
    t.datetime "posted_at"
    t.datetime "expires_at"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_jobs_on_category"
    t.index ["external_id", "source"], name: "index_jobs_on_external_id_and_source", unique: true
    t.index ["is_active"], name: "index_jobs_on_is_active"
    t.index ["posted_at"], name: "index_jobs_on_posted_at"
    t.index ["source"], name: "index_jobs_on_source"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "headline"
    t.text "bio"
    t.string "location"
    t.integer "years_of_experience", default: 0
    t.text "skills", default: [], array: true
    t.text "preferred_roles", default: [], array: true
    t.string "desired_role"
    t.integer "desired_salary_min"
    t.integer "desired_salary_max"
    t.string "remote_preference", default: "remote"
    t.string "timezone", default: "Asia/Kolkata"
    t.date "available_from"
    t.string "github_url"
    t.string "linkedin_url"
    t.string "portfolio_url"
    t.string "resume_url"
    t.string "photo_url"
    t.text "talent_brief"
    t.boolean "onboarding_completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_region", default: "anywhere", null: false
    t.string "salary_currency", default: "INR"
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plan", default: "free", null: false
    t.string "status", default: "active", null: false
    t.string "razorpay_subscription_id"
    t.string "razorpay_payment_id"
    t.string "order_id"
    t.datetime "started_at"
    t.datetime "expires_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan"], name: "index_subscriptions_on_plan"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "email_verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "job_matches", "jobs"
  add_foreign_key "job_matches", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "subscriptions", "users"
end
