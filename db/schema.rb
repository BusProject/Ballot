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

ActiveRecord::Schema.define(:version => 20120817173704) do

  create_table "choices", :force => true do |t|
    t.string    "contest"
    t.integer   "order"
    t.boolean   "commentable",  :default => false
    t.string    "geography"
    t.text      "description"
    t.string    "contest_type"
    t.timestamp "created_at",                      :null => false
    t.timestamp "updated_at",                      :null => false
  end

  add_index "choices", ["geography", "contest"], :name => "index_choices_on_geography_and_contest", :unique => true

  create_table "feedback", :force => true do |t|
    t.integer   "user_id"
    t.integer   "option_id"
    t.boolean   "support",    :default => false
    t.boolean   "approved",   :default => true
    t.text      "comment"
    t.timestamp "created_at",                    :null => false
    t.timestamp "updated_at",                    :null => false
    t.text      "useful",     :default => ""
    t.text      "flag",       :default => ""
    t.integer   "choice_id"
    t.text      "useless",    :default => ""
  end

  add_index "feedback", ["option_id"], :name => "index_feedback_on_option_id"
  add_index "feedback", ["user_id"], :name => "index_feedback_on_user_id"

  create_table "feedbacks", :force => true do |t|
    t.string    "choice_key"
    t.integer   "support",    :default => 0
    t.boolean   "approved",   :default => true
    t.text      "comment"
    t.integer   "user_id"
    t.timestamp "created_at",                   :null => false
    t.timestamp "updated_at",                   :null => false
  end

  add_index "feedbacks", ["choice_key"], :name => "index_feedbacks_on_choice_key"

  create_table "matches", :force => true do |t|
    t.string    "latlng"
    t.text      "data"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
  end

  add_index "matches", ["latlng"], :name => "index_matches_on_latlng", :unique => true

  create_table "memes", :force => true do |t|
    t.string    "image"
    t.text      "quote"
    t.integer   "feedback_id"
    t.string    "theme"
    t.boolean   "anomyous",    :default => false
    t.timestamp "created_at",                     :null => false
    t.timestamp "updated_at",                     :null => false
    t.string    "fb"
    t.string    "twitter"
    t.string    "tumblr"
    t.string    "imgur"
    t.string    "pintrest"
  end

  create_table "options", :force => true do |t|
    t.integer   "choice_id"
    t.integer   "position"
    t.string    "photo"
    t.text      "blurb"
    t.string    "name"
    t.timestamp "created_at",                      :null => false
    t.timestamp "updated_at",                      :null => false
    t.string    "twitter"
    t.string    "facebook"
    t.string    "website"
    t.string    "blurb_source"
    t.string    "party"
    t.boolean   "incumbant",    :default => false
  end

  add_index "options", ["choice_id"], :name => "index_options_on_choice_id"
  add_index "options", ["name"], :name => "index_options_on_name"

  create_table "users", :force => true do |t|
    t.string    "email",                  :default => "",    :null => false
    t.string    "encrypted_password",     :default => "",    :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",          :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at",                                :null => false
    t.timestamp "updated_at",                                :null => false
    t.string    "image"
    t.string    "name"
    t.string    "location"
    t.string    "url"
    t.string    "first_name"
    t.string    "last_name"
    t.boolean   "admin",                  :default => false
    t.string    "authentication_token"
    t.string    "guide_name"
    t.string    "base_address"
    t.string    "fb"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
