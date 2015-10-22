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

ActiveRecord::Schema.define(version: 20151019022903) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apps", force: :cascade do |t|
    t.string   "name"
    t.string   "icon_url"
    t.string   "link"
    t.string   "category"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "package_name"
  end

  add_index "apps", ["name"], name: "index_apps_on_name", using: :btree

  create_table "followers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "friendship_dt"
  end

  create_table "friends", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "friendship_dt"
  end

  create_table "metadata", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "product"
    t.string   "manufacturer"
    t.string   "brand"
    t.string   "model"
    t.string   "device"
    t.string   "display"
    t.string   "serial"
    t.string   "os"
    t.string   "os_codename"
    t.integer  "os_version"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "user_apps", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "twitter_id"
    t.string   "name"
    t.string   "screen_name"
    t.string   "location"
    t.text     "description"
    t.boolean  "is_contributors_enabled"
    t.string   "profile_image_url"
    t.string   "profile_image_url_https"
    t.boolean  "is_default_profile_image"
    t.string   "url"
    t.boolean  "is_protected"
    t.integer  "followers_count"
    t.integer  "status"
    t.string   "profile_background_color"
    t.string   "profile_text_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_use_background_image"
    t.boolean  "is_default_profile"
    t.boolean  "show_all_inline_media"
    t.integer  "friends_count"
    t.datetime "created_at",                         null: false
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.string   "profile_background_image_url"
    t.string   "profile_background_image_url_https"
    t.boolean  "profile_background_tiled"
    t.string   "language"
    t.integer  "statuses_count"
    t.boolean  "is_geo_enabled"
    t.boolean  "is_verified"
    t.boolean  "translator"
    t.integer  "listed_count"
    t.boolean  "is_follow_request_sent"
    t.datetime "updated_at",                         null: false
  end

  add_index "users", ["screen_name"], name: "index_users_on_screen_name", using: :btree

end
