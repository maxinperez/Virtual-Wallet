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

ActiveRecord::Schema[8.0].define(version: 2025_06_19_193259) do
  create_table "accounts", force: :cascade do |t|
    t.string "password_digest", null: false
    t.integer "user_id", null: false
    t.string "username"
    t.integer "admin"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "alias"
    t.string "cvu"
    t.decimal "balance"
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "holder_name"
    t.string "card_number"
    t.string "cvv"
    t.integer "exp_month"
    t.integer "exp_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bank_account_id"
    t.index ["bank_account_id"], name: "index_cards_on_bank_account_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.boolean "from_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "saving_goals", force: :cascade do |t|
    t.integer "bank_account_id"
    t.string "name"
    t.decimal "target_amount", precision: 10, scale: 2
    t.decimal "saved_amount", precision: 10, scale: 2, default: "0.0"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_saving_goals_on_bank_account_id"
  end

  create_table "saving_movements", force: :cascade do |t|
    t.integer "saving_goal_id", null: false
    t.integer "transaction_type", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["saving_goal_id"], name: "index_saving_movements_on_saving_goal_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "source_account_id"
    t.integer "target_account_id"
    t.integer "amount", null: false
    t.datetime "transaction_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "motivo"
    t.integer "transaction_type"
    t.integer "state"
    t.string "transfer_cod"
    t.string "comprobante_cod"
    t.index ["source_account_id"], name: "index_transactions_on_source_account_id"
    t.index ["target_account_id"], name: "index_transactions_on_target_account_id"
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
  add_foreign_key "cards", "bank_accounts"
  add_foreign_key "messages", "accounts", column: "user_id"
  add_foreign_key "saving_goals", "bank_accounts"
  add_foreign_key "saving_movements", "saving_goals"
  add_foreign_key "transactions", "bank_accounts", column: "source_account_id"
  add_foreign_key "transactions", "bank_accounts", column: "target_account_id"
end
