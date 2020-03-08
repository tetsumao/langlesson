# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_01_164819) do

  create_table "categories", force: :cascade do |t|
    t.string "category_name"
    t.integer "dspo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "date_at"
    t.integer "period_id", null: false
    t.integer "category_id"
    t.integer "ticket_id"
    t.string "zoom_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "feedback"
    t.text "report"
    t.index ["category_id"], name: "index_lessons_on_category_id"
    t.index ["period_id"], name: "index_lessons_on_period_id"
    t.index ["ticket_id"], name: "index_lessons_on_ticket_id"
    t.index ["user_id"], name: "index_lessons_on_user_id"
  end

  create_table "periods", force: :cascade do |t|
    t.string "start_time"
    t.string "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "number_owned", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "due_at"
    t.string "stripe_invid"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer "user_id"
    t.integer "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_user_categories_on_category_id"
    t.index ["user_id", "category_id"], name: "index_user_categories_on_user_id_and_category_id", unique: true
    t.index ["user_id"], name: "index_user_categories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "user_name"
    t.string "picture"
    t.text "profile"
    t.integer "authority", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_cusid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "lessons", "categories"
  add_foreign_key "lessons", "periods"
  add_foreign_key "lessons", "tickets"
  add_foreign_key "lessons", "users"
  add_foreign_key "tickets", "users"
  add_foreign_key "user_categories", "categories"
  add_foreign_key "user_categories", "users"
end
