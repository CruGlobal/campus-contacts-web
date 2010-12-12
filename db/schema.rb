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

ActiveRecord::Schema.define(:version => 20101212050432) do

  create_table "received_sms", :force => true do |t|
    t.string   "phone_number"
    t.string   "carrier"
    t.string   "shortcode"
    t.string   "message"
    t.string   "country"
    t.string   "person_id"
    t.datetime "received_at"
    t.boolean  "followed_up",    :default => false
    t.boolean  "assigned_to_id"
    t.boolean  "integer"
    t.integer  "response_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_sms", :force => true do |t|
    t.string   "message"
    t.integer  "recipient"
    t.text     "reports"
    t.string   "moonshado_claimcheck"
    t.string   "sent_via"
    t.integer  "recieved_sms_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_keywords", :force => true do |t|
    t.string   "keyword"
    t.integer  "local_level_id"
    t.string   "name"
    t.integer  "target_area_id"
    t.string   "chartfield"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
