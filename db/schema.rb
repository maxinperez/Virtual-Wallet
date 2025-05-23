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

ActiveRecord::Schema[8.0].define(version: 2025_05_23_044228) do
  create_table "accounts", force: :cascade do |t|
    t.string "password_digest", null: false
    t.integer "user_id", null: false
    t.string "username"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "alias"
    t.string "cvu"
    t.decimal "balance"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "sender_bank_account_id"
    t.integer "receiver_bank_account_id"
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "transaction_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_bank_account_id"], name: "index_transactions_on_receiver_bank_account_id"
    t.index ["sender_bank_account_id"], name: "index_transactions_on_sender_bank_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "dni", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "locality", null: false
    t.string "cp", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "bank_accounts", "users"
  add_foreign_key "transactions", "bank_accounts", column: "receiver_bank_account_id"
  add_foreign_key "transactions", "bank_accounts", column: "sender_bank_account_id"
end
