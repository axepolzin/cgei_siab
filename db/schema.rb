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

ActiveRecord::Schema.define(version: 20160605232048) do

  create_table "owners", force: :cascade do |t|
    t.string   "tax_city"
    t.string   "tax_state"
    t.string   "tax_zip"
    t.string   "formatted_tax_address"
    t.float    "tax_lat"
    t.float    "tax_long"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "properties", force: :cascade do |t|
    t.string   "pin"
    t.float    "lat"
    t.float    "long"
    t.string   "address"
    t.string   "address_number"
    t.string   "address_rose"
    t.string   "address_street"
    t.string   "address_suffix"
    t.string   "address_formatted"
    t.string   "city"
    t.string   "township"
    t.string   "zip"
    t.string   "property_class"
    t.string   "name"
    t.string   "tax_address"
    t.string   "tax_street_number"
    t.string   "tax_street_rose"
    t.string   "tax_street_name"
    t.string   "tax_street_suffix"
    t.string   "tax_city"
    t.string   "tax_state"
    t.string   "tax_zip"
    t.string   "formatted_tax_address"
    t.float    "tax_lat"
    t.float    "tax_long"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "owner_id"
    t.string   "owner_occupied"
  end

end
