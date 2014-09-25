class InitSchema < ActiveRecord::Migration
  def up
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
      t.integer  "recipient_id"
      t.integer  "notification_id"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "activities", ["creator_id"], name: "index_activities_on_creator_id", using: :btree
    add_index "activities", ["recipient_id"], name: "index_activities_on_recipient_id", using: :btree
    add_index "activities", ["subject_id"], name: "index_activities_on_subject_id", using: :btree
    add_index "activities", ["subject_type", "action_type"], name: "index_activities_on_subject_type_and_action_type", using: :btree

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
    end

    add_index "authentications", ["deleted_at"], name: "index_authentications_on_deleted_at", using: :btree
    add_index "authentications", ["uid", "name"], name: "index_authentications_on_uid_and_name", using: :btree
    add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

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
    end

    add_index "items", ["creator_id"], name: "index_items_on_creator_id", using: :btree
    add_index "items", ["morsel_id"], name: "index_items_on_post_id", using: :btree

    create_table "keywords", force: true do |t|
      t.string   "type"
      t.string   "name"
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

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
      t.hstore   "mrsl"
      t.integer  "place_id"
      t.integer  "template_id"
    end

    add_index "morsels", ["cached_slug"], name: "index_morsels_on_cached_slug", using: :btree
    add_index "morsels", ["creator_id"], name: "index_morsels_on_creator_id", using: :btree
    add_index "morsels", ["place_id"], name: "index_morsels_on_place_id", using: :btree

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

    add_index "notifications", ["payload_type"], name: "index_notifications_on_payload_type", using: :btree
    add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

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
    end

    add_index "places", ["name", "foursquare_venue_id"], name: "index_places_on_name_and_foursquare_venue_id", using: :btree

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
    end

    add_index "user_events", ["name"], name: "index_user_events_on_name", using: :btree
    add_index "user_events", ["user_id"], name: "index_user_events_on_user_id", using: :btree

    create_table "users", force: true do |t|
      t.string   "email",                  default: "",         null: false
      t.string   "encrypted_password",     default: "",         null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,          null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name"
      t.string   "last_name"
      t.boolean  "admin",                  default: false,      null: false
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

  end

  def down
    raise "Can not revert initial migration"
  end
end
