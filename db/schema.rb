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

ActiveRecord::Schema.define(version: 20150717094716) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "id_number"
    t.string   "email"
    t.string   "twitter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "daily_start_time"
    t.string   "daily_end_time"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "ticket_type_id"
    t.integer  "quantity"
    t.integer  "total_amount_cents"
    t.string   "ip"
    t.string   "express_token"
    t.string   "express_payer_id"
    t.text     "notes"
    t.datetime "purchased_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "orders", ["ticket_type_id"], name: "index_orders_on_ticket_type_id", using: :btree

  create_table "ticket_types", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "name"
    t.text     "description"
    t.decimal  "strikethrough_price", precision: 5, scale: 2
    t.decimal  "price",               precision: 5, scale: 2
    t.integer  "quota"
    t.boolean  "hidden"
    t.string   "code"
    t.boolean  "active"
    t.datetime "sale_starts_at"
    t.datetime "sale_ends_at"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "ticket_types", ["event_id"], name: "index_ticket_types_on_event_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "attendee_id"
    t.text     "notes"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tickets", ["attendee_id"], name: "index_tickets_on_attendee_id", using: :btree
  add_index "tickets", ["order_id"], name: "index_tickets_on_order_id", using: :btree

  add_foreign_key "orders", "ticket_types"
  add_foreign_key "ticket_types", "events"
  add_foreign_key "tickets", "attendees"
  add_foreign_key "tickets", "orders"
end
