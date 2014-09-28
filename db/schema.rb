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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140927051218) do

  create_table "blocks", :force => true do |t|
    t.integer  "guide_id"
    t.integer  "option_id"
    t.integer  "user_option_id"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "order"
    t.boolean  "full_size"
  end

  add_index "blocks", ["guide_id"], :name => "index_blocks_on_guide_id"
  add_index "blocks", ["option_id"], :name => "index_blocks_on_option_id"
  add_index "blocks", ["user_option_id"], :name => "index_blocks_on_user_option_id"

  create_table "choices", :force => true do |t|
    t.string   "contest"
    t.boolean  "commentable",        :default => false
    t.string   "geography"
    t.text     "description"
    t.string   "contest_type"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "votes",              :default => 1
    t.integer  "external_id"
    t.binary   "fiscal_impact"
    t.binary   "description_source"
  end

  add_index "choices", ["external_id"], :name => "index_choices_on_external_id"

  create_table "feedback", :force => true do |t|
    t.integer  "user_id"
    t.integer  "option_id"
    t.boolean  "approved",           :default => true
    t.text     "comment"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "flag",               :default => ""
    t.integer  "choice_id"
    t.integer  "cached_votes_total", :default => 0
    t.integer  "cached_votes_up",    :default => 0
    t.integer  "cached_votes_down",  :default => 0
  end

  add_index "feedback", ["cached_votes_down"], :name => "index_feedback_on_cached_votes_down"
  add_index "feedback", ["cached_votes_total"], :name => "index_feedback_on_cached_votes_total"
  add_index "feedback", ["cached_votes_up"], :name => "index_feedback_on_cached_votes_up"
  add_index "feedback", ["option_id"], :name => "index_feedback_on_option_id"
  add_index "feedback", ["user_id"], :name => "index_feedback_on_user_id"

  create_table "guides", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "publish"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  add_index "guides", ["user_id"], :name => "index_guides_on_user_id"

  create_table "matches", :force => true do |t|
    t.string   "latlng"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "matches", ["latlng"], :name => "index_matches_on_latlng", :unique => true

  create_table "options", :force => true do |t|
    t.integer  "choice_id"
    t.string   "photo"
    t.text     "blurb"
    t.string   "name"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "party"
    t.integer  "external_id"
    t.boolean  "incumbent",   :default => false
  end

  add_index "options", ["choice_id"], :name => "index_options_on_choice_id"
  add_index "options", ["external_id"], :name => "index_options_on_external_id"
  add_index "options", ["name"], :name => "index_options_on_name"

  create_table "user_options", :force => true do |t|
    t.integer  "choice_id"
    t.integer  "user_id"
    t.integer  "position"
    t.string   "photo"
    t.text     "blurb"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_options", ["choice_id"], :name => "index_user_options_on_choice_id"
  add_index "user_options", ["name"], :name => "index_user_options_on_name"
  add_index "user_options", ["user_id"], :name => "index_user_options_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "image"
    t.string   "name"
    t.string   "location"
    t.string   "url"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                  :default => false
    t.string   "authentication_token"
    t.string   "guide_name"
    t.string   "fb"
    t.boolean  "banned",                 :default => false
    t.boolean  "deactivated",            :default => false
    t.text     "description"
    t.text     "fb_friends"
    t.text     "alerts"
    t.text     "pages"
    t.string   "profile"
    t.string   "primary"
    t.string   "secondary"
    t.string   "bg"
    t.string   "header_file_name"
    t.string   "header_content_type"
    t.integer  "header_file_size"
    t.datetime "header_updated_at"
    t.integer  "match_id"
    t.string   "address"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "votes", ["votable_id", "votable_type"], :name => "index_votes_on_votable_id_and_votable_type"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
