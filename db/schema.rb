# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160423003815) do

  create_table "image_label_sets", force: :cascade do |t|
    t.integer  "image_set_id"
    t.integer  "label_set_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "image_label_sets", ["image_set_id"], name: "index_image_label_sets_on_image_set_id"
  add_index "image_label_sets", ["label_set_id"], name: "index_image_label_sets_on_label_set_id"
  add_index "image_label_sets", ["user_id"], name: "index_image_label_sets_on_user_id"

  create_table "image_labels", force: :cascade do |t|
    t.integer  "image_id"
    t.integer  "label_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "job_id"
  end

  add_index "image_labels", ["image_id"], name: "index_image_labels_on_image_id"
  add_index "image_labels", ["label_id"], name: "index_image_labels_on_label_id"

  create_table "image_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name",       null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "filename"
    t.integer  "image_set_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "images", ["image_set_id"], name: "index_images_on_image_set_id"

  create_table "jobs", force: :cascade do |t|
    t.integer  "image_label_set_id"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "jobs", ["image_label_set_id"], name: "index_jobs_on_image_label_set_id"
  add_index "jobs", ["user_id"], name: "index_jobs_on_user_id"

  create_table "label_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "labels", force: :cascade do |t|
    t.string   "text"
    t.integer  "label_set_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "labels", ["label_set_id"], name: "index_labels_on_label_set_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_admin",               default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
