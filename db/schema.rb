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

ActiveRecord::Schema.define(version: 2019_05_12_135122) do
  create_table "maps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "turn_id"
    t.index ["turn_id"], name: "index_maps_on_turn_id"
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "turn_id"
    t.bigint "power_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "unit_id"
    t.string "dest"
    t.integer "phase"
    t.integer "status"
    t.string "target"
    t.string "keepout"
    t.index ["power_id"], name: "index_orders_on_power_id"
    t.index ["turn_id"], name: "index_orders_on_turn_id"
    t.index ["unit_id"], name: "index_orders_on_unit_id"
  end

  create_table "players", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "table_id"
    t.bigint "user_id"
    t.bigint "power_id"
    t.index ["power_id"], name: "index_players_on_power_id"
    t.index ["table_id"], name: "index_players_on_table_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "powers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "table_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
    t.string "name"
    t.string "genitive"
    t.bigint "player_id"
    t.string "jname"
    t.index ["player_id"], name: "index_powers_on_player_id"
    t.index ["table_id"], name: "index_powers_on_table_id"
  end

  create_table "provinces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.bigint "turn_id"
    t.string "code"
    t.string "power"
    t.boolean "supplycenter"
    t.string "name"
    t.string "jname"
    t.index ["turn_id"], name: "index_provinces_on_turn_id"
  end

  create_table "regulations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "face_type"
    t.integer "period_rule"
    t.integer "duration"
    t.string "keyword"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "due_date"
    t.string "start_time"
    t.boolean "stand_by"
  end

  create_table "tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "turn"
    t.integer "phase"
    t.bigint "regulation_id"
    t.datetime "period"
    t.datetime "last_nego_period"
    t.integer "status"
    t.index ["regulation_id"], name: "index_tables_on_regulation_id"
  end

  create_table "turns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "table_id"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["table_id"], name: "index_turns_on_table_id"
  end

  create_table "units", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "turn_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "phase"
    t.string "province"
    t.string "keepout"
    t.bigint "power_id"
    t.index ["power_id"], name: "index_units_on_power_id"
    t.index ["turn_id"], name: "index_units_on_turn_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "token", collation: "utf8_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
    t.string "image_url"
    t.string "nickname"
    t.string "url"
    t.boolean "admin", default: false
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "maps", "turns"
  add_foreign_key "orders", "powers"
  add_foreign_key "orders", "turns"
  add_foreign_key "orders", "units"
  add_foreign_key "players", "powers"
  add_foreign_key "players", "tables"
  add_foreign_key "players", "users"
  add_foreign_key "powers", "players"
  add_foreign_key "powers", "tables"
  add_foreign_key "provinces", "turns"
  add_foreign_key "tables", "regulations"
  add_foreign_key "turns", "tables"
  add_foreign_key "units", "turns"
end
