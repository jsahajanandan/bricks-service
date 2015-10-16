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

ActiveRecord::Schema.define(version: 20151016073501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "development_plans", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "num_floors",                                                        null: false
    t.integer  "num_flats",                                                         null: false
    t.integer  "flat_type",          limit: 2,                          default: 0
    t.float    "flat_area",                                                         null: false
    t.decimal  "flat_selling_price",           precision: 20, scale: 2,             null: false
    t.date     "completion_date",                                                   null: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  add_index "development_plans", ["project_id"], name: "index_development_plans_on_project_id", unique: true, using: :btree

  create_table "financials", force: :cascade do |t|
    t.integer  "project_id"
    t.decimal  "land_cost",               precision: 20, scale: 2, null: false
    t.decimal  "investment_sum_required", precision: 20, scale: 2, null: false
    t.integer  "num_bricks",                                       null: false
    t.decimal  "brick_value",             precision: 20, scale: 2, null: false
    t.decimal  "personal_investment",     precision: 20, scale: 2, null: false
    t.integer  "time_frame_days",                                  null: false
    t.text     "roi_pitch"
    t.boolean  "is_active"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "financials", ["project_id"], name: "index_financials_on_project_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id",                           null: false
    t.integer  "listing_id",                        null: false
    t.integer  "project_tag", limit: 2, default: 0
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "projects", ["listing_id"], name: "index_projects_on_listing_id", unique: true, using: :btree

end
