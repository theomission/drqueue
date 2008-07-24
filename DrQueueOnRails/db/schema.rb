# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "jobs", :force => true do |t|
    t.integer "queue_id",   :limit => 11
    t.string  "renderer"
    t.string  "sort"
    t.integer "profile_id", :limit => 11
  end

  create_table "profiles", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "avatar"
    t.string  "ldap_account"
    t.string  "status"
    t.integer "accepted",     :limit => 11, :default => 0
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

end