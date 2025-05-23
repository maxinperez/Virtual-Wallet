# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_21_233918) do
  create_table "accounts", force: :cascade do |t|
    t.string "dni"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "bankaccounts", force: :cascade do |t|
    t.string "account_number", null: false
    t.string "alias", null: false
    t.string "dni", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "balance"
    t.index ["account_number"], name: "unique_global_account_number", unique: true
    t.index ["alias"], name: "unique_global_alias", unique: true
    t.index ["dni"], name: "index_bankaccounts_on_dni"
  end

  create_table "transactions", primary_key: "id_transaction", id: :string, force: :cascade do |t|
    t.datetime "date_transaction", null: false
    t.integer "state", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.integer "dni"
    t.string "email"
    t.string "situation"
    t.string "locality"
    t.string "address"
    t.integer "cp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.index ["dni"], name: "index_users_on_dni", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users", column: "dni", primary_key: "dni"
  add_foreign_key "accounts", "users", column: "dni", primary_key: "dni", on_delete: :cascade
end
