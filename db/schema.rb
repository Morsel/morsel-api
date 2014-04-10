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

ActiveRecord::Schema.define(version: 20140409200432) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "action_id"
    t.string   "action_type"
    t.integer  "creator_id"
    t.integer  "recipient_id"
    t.integer  "notification_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["creator_id"], name: "index_activities_on_creator_id", using: :btree
  add_index "activities", ["recipient_id"], name: "index_activities_on_recipient_id", using: :btree
  add_index "activities", ["subject_id"], name: "index_activities_on_subject_id", using: :btree

  create_table "authorizations", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["uid", "name"], name: "index_authorizations_on_uid_and_name", using: :btree
  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id", "item_id"], name: "index_comments_on_user_id_and_item_id", using: :btree

  create_table "emails", force: true do |t|
    t.string   "class_name"
    t.string   "template_name"
    t.string   "from_email"
    t.string   "from_name"
    t.boolean  "stop_sending",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["class_name"], name: "index_emails_on_class_name", unique: true, using: :btree

  create_table "feed_items", force: true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.datetime "deleted_at"
    t.boolean  "visible",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_items", ["subject_id", "subject_type"], name: "index_feed_items_on_subject_id_and_subject_type", using: :btree

  create_table "follows", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "photo"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.string   "nonce"
    t.boolean  "photo_processing"
    t.integer  "morsel_id"
    t.integer  "sort_order"
  end

  add_index "items", ["creator_id"], name: "index_items_on_creator_id", using: :btree
  add_index "items", ["morsel_id"], name: "index_items_on_post_id", using: :btree

  create_table "likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["user_id", "item_id"], name: "index_likes_on_user_id_and_item_id", using: :btree

  create_table "morsels", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "cached_slug"
    t.datetime "deleted_at"
    t.boolean  "draft",              default: true, null: false
    t.datetime "published_at"
    t.integer  "primary_item_id"
    t.string   "photo"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "morsels", ["cached_slug"], name: "index_morsels_on_cached_slug", using: :btree
  add_index "morsels", ["creator_id"], name: "index_morsels_on_creator_id", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "payload_id"
    t.string   "payload_type"
    t.string   "message"
    t.integer  "user_id"
    t.datetime "marked_read_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "slugs", force: true do |t|
    t.string   "scope"
    t.string   "slug"
    t.integer  "record_id"
    t.datetime "created_at"
  end

  add_index "slugs", ["scope", "record_id", "created_at"], name: "index_slugs_on_scope_and_record_id_and_created_at", using: :btree
  add_index "slugs", ["scope", "record_id"], name: "index_slugs_on_scope_and_record_id", using: :btree
  add_index "slugs", ["scope", "slug", "created_at"], name: "index_slugs_on_scope_and_slug_and_created_at", using: :btree
  add_index "slugs", ["scope", "slug"], name: "index_slugs_on_scope_and_slug", using: :btree

  create_table "user_events", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "client_version"
    t.string   "client_device"
    t.text     "__utmz"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_events", ["name"], name: "index_user_events_on_name", using: :btree
  add_index "user_events", ["user_id"], name: "index_user_events_on_user_id", using: :btree

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                  default: false, null: false
    t.string   "authentication_token"
    t.string   "photo"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "title"
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.string   "bio"
    t.boolean  "active",                 default: true
    t.datetime "verified_at"
    t.string   "industry"
    t.boolean  "unsubscribed",           default: false
    t.boolean  "photo_processing"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
