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


ActiveRecord::Schema.define(version: 20151204104048) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"

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
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",       default: false
  end

  add_index "activities", ["creator_id"], name: "index_activities_on_creator_id", using: :btree
  add_index "activities", ["subject_id"], name: "index_activities_on_subject_id", using: :btree
  add_index "activities", ["subject_type", "action_type"], name: "index_activities_on_subject_type_and_action_type", using: :btree

  create_table "activity_logs", force: true do |t|
    t.string   "ip_address"
    t.string   "host_site"
    t.string   "share_by"
    t.string   "activity"
    t.integer  "activity_id"
    t.string   "activity_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_logs", ["activity_id"], name: "index_activity_logs_on_activity_id", using: :btree

  create_table "activity_subscriptions", force: true do |t|
    t.integer  "subscriber_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "action",        default: 0
    t.integer  "reason",        default: 0
    t.boolean  "active",        default: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_subscriptions", ["subject_id", "subject_type"], name: "index_activity_subscriptions_on_subject_id_and_subject_type", using: :btree
  add_index "activity_subscriptions", ["subscriber_id"], name: "index_activity_subscriptions_on_subscriber_id", using: :btree

  create_table "associated_morsels", force: true do |t|
    t.integer  "morsel_id"
    t.integer  "host_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "association_requests", force: true do |t|
    t.integer  "host_id",                            null: false
    t.integer  "associated_user_id",                 null: false
    t.boolean  "approved",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.text     "token"
    t.string   "secret"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "email"
  end

  add_index "authentications", ["deleted_at"], name: "index_authentications_on_deleted_at", using: :btree
  add_index "authentications", ["uid", "name"], name: "index_authentications_on_uid_and_name", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "collection_morsels", force: true do |t|
    t.integer  "collection_id"
    t.integer  "morsel_id"
    t.integer  "sort_order"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
  end

  add_index "collection_morsels", ["collection_id"], name: "index_collection_morsels_on_collection_id", using: :btree
  add_index "collection_morsels", ["morsel_id"], name: "index_collection_morsels_on_morsel_id", using: :btree

  create_table "collections", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "place_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
  end

  add_index "collections", ["cached_slug"], name: "index_collections_on_cached_slug", using: :btree
  add_index "collections", ["place_id"], name: "index_collections_on_place_id", using: :btree
  add_index "collections", ["user_id"], name: "index_collections_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commenter_id"
    t.integer  "commentable_id"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type"
  end

  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["commenter_id", "commentable_id"], name: "index_comments_on_commenter_id_and_commentable_id", using: :btree

  create_table "devices", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "token"
    t.string   "model"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.hstore   "notification_settings", default: {}
  end

  add_index "devices", ["deleted_at"], name: "index_devices_on_deleted_at", using: :btree
  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "email_logs", force: true do |t|
    t.integer  "morsel_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_logs", ["morsel_id"], name: "index_email_logs_on_morsel_id", using: :btree
  add_index "email_logs", ["user_id"], name: "index_email_logs_on_user_id", using: :btree

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

  create_table "employments", force: true do |t|
    t.integer  "place_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "employments", ["place_id", "user_id"], name: "index_employments_on_place_id_and_user_id", using: :btree

  create_table "feed_items", force: true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.datetime "deleted_at"
    t.boolean  "visible",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "featured",     default: false
    t.integer  "place_id"
  end

  add_index "feed_items", ["featured"], name: "index_feed_items_on_featured", using: :btree
  add_index "feed_items", ["place_id"], name: "index_feed_items_on_place_id", using: :btree
  add_index "feed_items", ["subject_id", "subject_type"], name: "index_feed_items_on_subject_id_and_subject_type", using: :btree
  add_index "feed_items", ["user_id"], name: "index_feed_items_on_user_id", using: :btree

  create_table "follows", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "followable_type"
    t.datetime "deleted_at"
  end

  add_index "follows", ["created_at"], name: "index_follows_on_created_at", using: :btree
  add_index "follows", ["followable_id", "follower_id"], name: "index_follows_on_followable_id_and_follower_id", using: :btree
  add_index "follows", ["followable_type"], name: "index_follows_on_followable_type", using: :btree

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
    t.integer  "template_order"
    t.integer  "comments_count",     default: 0, null: false
    t.string   "cached_url"
  end

  add_index "items", ["creator_id"], name: "index_items_on_creator_id", using: :btree
  add_index "items", ["morsel_id"], name: "index_items_on_post_id", using: :btree

  create_table "keywords", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "followers_count", default: 0,     null: false
    t.boolean  "promoted",        default: false
    t.integer  "tags_count",      default: 0,     null: false
  end

  add_index "keywords", ["promoted"], name: "index_keywords_on_promoted", using: :btree
  add_index "keywords", ["type"], name: "index_keywords_on_type", using: :btree

  create_table "likes", force: true do |t|
    t.integer  "liker_id"
    t.integer  "likeable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "likeable_type"
  end

  add_index "likes", ["likeable_type"], name: "index_likes_on_likeable_type", using: :btree
  add_index "likes", ["liker_id", "likeable_id"], name: "index_likes_on_liker_id_and_likeable_id", using: :btree

  create_table "morsel_keywords", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "morsel_morsel_keywords", force: true do |t|
    t.integer  "morsel_id"
    t.integer  "morsel_keyword_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "morsel_morsel_topics", force: true do |t|
    t.integer  "morsel_id"
    t.integer  "morsel_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "morsel_topics", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "morsel_user_tags", force: true do |t|
    t.integer  "morsel_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "morsel_user_tags", ["morsel_id", "user_id"], name: "index_morsel_user_tags_on_morsel_id_and_user_id", using: :btree

  create_table "morsels", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "cached_slug"
    t.datetime "deleted_at"
    t.boolean  "draft",                      default: true,  null: false
    t.datetime "published_at"
    t.integer  "primary_item_id"
    t.string   "photo"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.datetime "photo_updated_at"
    t.hstore   "mrsl"
    t.integer  "place_id"
    t.integer  "template_id"
    t.integer  "likes_count",                default: 0,     null: false
    t.string   "cached_url"
    t.text     "summary"
    t.integer  "tagged_users_count",         default: 0,     null: false
    t.boolean  "publishing",                 default: false
    t.hstore   "cached_primary_item_photos"
    t.boolean  "news_letter_sent",           default: false
    t.boolean  "is_submit",                  default: false
    t.datetime "schedual_date"
    t.text     "morsel_video"
    t.text     "video_text"

  end

  add_index "morsels", ["cached_slug"], name: "index_morsels_on_cached_slug", using: :btree
  add_index "morsels", ["creator_id"], name: "index_morsels_on_creator_id", using: :btree
  add_index "morsels", ["place_id"], name: "index_morsels_on_place_id", using: :btree
  add_index "morsels", ["updated_at", "published_at"], name: "index_morsels_on_updated_at_and_published_at", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "payload_id"
    t.string   "payload_type"
    t.text     "message"
    t.integer  "user_id"
    t.datetime "marked_read_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
    t.string   "reason"
  end

  add_index "notifications", ["payload_type"], name: "index_notifications_on_payload_type", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "pg_search_documents", force: true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "places", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "facebook_page_id"
    t.string   "twitter_username"
    t.string   "foursquare_venue_id"
    t.json     "foursquare_timeframes"
    t.hstore   "information",           default: {}
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "last_imported_at"
    t.float    "lat"
    t.float    "lon"
    t.string   "widget_url"
    t.integer  "followers_count",       default: 0,  null: false
  end

  add_index "places", ["name", "foursquare_venue_id"], name: "index_places_on_name_and_foursquare_venue_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "host_url"
    t.string   "host_logo"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",      default: false
    t.string   "company_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "preview_text"
  end

  create_table "remote_notifications", force: true do |t|
    t.integer  "device_id"
    t.integer  "notification_id"
    t.integer  "user_id"
    t.string   "activity_type"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_notifications", ["device_id"], name: "index_remote_notifications_on_device_id", using: :btree
  add_index "remote_notifications", ["notification_id"], name: "index_remote_notifications_on_notification_id", using: :btree
  add_index "remote_notifications", ["user_id"], name: "index_remote_notifications_on_user_id", using: :btree

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

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "keyword_id"
  end

  create_table "tags", force: true do |t|
    t.integer  "tagger_id"
    t.integer  "keyword_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["taggable_type"], name: "index_tags_on_taggable_type", using: :btree
  add_index "tags", ["tagger_id", "taggable_id", "keyword_id"], name: "index_tags_on_tagger_id_and_taggable_id_and_keyword_id", using: :btree

  create_table "user_events", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "client_version"
    t.string   "client_device"
    t.text     "__utmz"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "properties",     default: {}
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
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.string   "bio"
    t.boolean  "active",                 default: true
    t.datetime "verified_at"
    t.string   "industry"
    t.boolean  "photo_processing"
    t.boolean  "staff",                  default: false
    t.datetime "deleted_at"
    t.boolean  "promoted",               default: false
    t.hstore   "settings",               default: {}
    t.boolean  "professional",           default: false
    t.boolean  "password_set",           default: true
    t.integer  "drafts_count",           default: 0,     null: false
    t.integer  "followed_users_count",   default: 0,     null: false
    t.integer  "followers_count",        default: 0,     null: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["promoted", "first_name", "last_name"], name: "index_users_on_promoted_and_first_name_and_last_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
