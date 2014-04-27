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

ActiveRecord::Schema.define(version: 20140302225436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "choices", force: true do |t|
    t.string   "contest"
    t.integer  "order"
    t.boolean  "commentable",       default: false
    t.string   "geography"
    t.text     "description"
    t.string   "contest_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes",             default: 1
    t.integer  "electionballot_id"
  end

  add_index "choices", ["geography", "contest", "electionballot_id"], name: "index_choices_on_geography_and_contest_and_electionballot_id", unique: true, using: :btree

  create_table "districts", force: true do |t|
    t.string   "name"
    t.text     "shape"
    t.string   "geography"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "electionballots", force: true do |t|
    t.integer  "electionday_id"
    t.string   "name"
    t.text     "notes"
    t.boolean  "open",           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "electiondays", force: true do |t|
    t.date     "date"
    t.string   "election_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", force: true do |t|
    t.string   "latlng"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches", ["latlng"], name: "index_matches_on_latlng", unique: true, using: :btree

  create_table "options", force: true do |t|
    t.integer  "choice_id"
    t.integer  "position"
    t.string   "photo"
    t.text     "blurb"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "blurb_source"
    t.string   "party"
    t.boolean  "incumbant",    default: false
    t.string   "vip_id"
  end

  add_index "options", ["choice_id"], name: "index_options_on_choice_id", using: :btree
  add_index "options", ["name"], name: "index_options_on_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.string   "name"
    t.string   "location"
    t.string   "url"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                  default: false
    t.string   "authentication_token"
    t.string   "guide_name"
    t.string   "fb"
    t.boolean  "banned",                 default: false
    t.boolean  "deactivated",            default: false
    t.text     "description"
    t.text     "fb_friends"
    t.text     "alerts"
    t.text     "pages"
    t.string   "profile"
    t.string   "primary"
    t.string   "secondary"
    t.string   "bg"
    t.integer  "match_id"
    t.string   "address"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

end
