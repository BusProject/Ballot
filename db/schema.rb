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

ActiveRecord::Schema.define(:version => 20120524232152) do

  create_table "choices", :force => true do |t|
    t.string   "contest"
    t.integer  "order"
    t.boolean  "commentable",  :default => false
    t.string   "geography"
    t.text     "description"
    t.string   "contest_type"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "choices", ["geography", "contest"], :name => "index_choices_on_geography_and_contest", :unique => true

  create_table "feedback", :force => true do |t|
    t.integer  "user_id"
    t.integer  "option_id"
    t.boolean  "support",    :default => false
    t.boolean  "approved",   :default => true
    t.text     "comment"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "feedback", ["option_id"], :name => "index_feedback_on_option_id"
  add_index "feedback", ["user_id"], :name => "index_feedback_on_user_id"

  create_table "matches", :force => true do |t|
    t.string   "latlng"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "matches", ["latlng"], :name => "index_matches_on_latlng", :unique => true

  create_table "options", :force => true do |t|
    t.integer  "choice_id"
    t.integer  "position"
    t.string   "photo"
    t.text     "blurb"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "options", ["choice_id"], :name => "index_options_on_choice_id"
  add_index "options", ["name"], :name => "index_options_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
