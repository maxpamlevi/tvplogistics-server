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

ActiveRecord::Schema[7.1].define(version: 2024_11_30_035802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "business_plans", force: :cascade do |t|
    t.string "contract"
    t.date "start"
    t.date "end"
    t.integer "status"
    t.string "bill_of_lading"
    t.integer "service_order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_business_plans_on_deleted_at"
  end

  create_table "customers", force: :cascade do |t|
    t.string "customer_no"
    t.string "name"
    t.string "address"
    t.string "tax_no"
    t.integer "dept", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "debit_notes", force: :cascade do |t|
    t.string "so"
    t.string "customer"
    t.date "date"
    t.text "description"
    t.float "quantity"
    t.float "unit_price"
    t.float "amount"
    t.float "amount_vat"
    t.float "deposit"
    t.date "payment_date"
    t.string "uom"
    t.string "allow"
    t.string "refund"
    t.integer "service_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "compensation"
    t.float "vat", default: 0.0
    t.string "contract"
    t.string "branch", default: "tvpl"
    t.datetime "deleted_at"
    t.integer "status", default: 0
    t.integer "user_id"
    t.integer "group_id"
    t.index ["deleted_at"], name: "index_debit_notes_on_deleted_at"
  end

  create_table "file_data", force: :cascade do |t|
    t.string "file_internal_id"
    t.string "file_external_id"
    t.string "file_discharge_id"
    t.string "file_load_id"
    t.string "file_truck_id"
    t.string "file_barge_id"
    t.integer "service_order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_so_load"
    t.string "file_so_disc"
    t.string "file_so_cont"
    t.string "file_so_bk"
    t.string "file"
  end

  create_table "payment_requests", force: :cascade do |t|
    t.string "so"
    t.date "payment_date"
    t.string "requested_by"
    t.string "dept"
    t.string "pr_no"
    t.string "invoice_no"
    t.string "payment_vendor"
    t.date "invoice_date"
    t.text "description"
    t.float "quantity"
    t.float "unit_price"
    t.float "amount"
    t.float "amount_vat"
    t.date "docs_date"
    t.date "payment_due_date"
    t.string "payment_status"
    t.string "remark"
    t.string "uom"
    t.string "allow"
    t.integer "service_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "vat", default: 0.0
    t.string "branch", default: "tvpl"
    t.datetime "deleted_at"
    t.integer "status", default: 0
    t.integer "user_id"
    t.integer "group_id"
    t.index ["deleted_at"], name: "index_payment_requests_on_deleted_at"
  end

  create_table "results", force: :cascade do |t|
    t.float "tvpl_load", default: 0.0
    t.float "discharge", default: 0.0
    t.float "tvpl_truck", default: 0.0
    t.float "tvpl_barge", default: 0.0
    t.float "internal_wh", default: 0.0
    t.float "external_wh", default: 0.0
    t.float "total_wh", default: 0.0
    t.float "grand_total", default: 0.0
    t.float "revenue", default: 0.0
    t.float "cost", default: 0.0
    t.float "profit", default: 0.0
    t.integer "service_order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_results_on_deleted_at"
  end

  create_table "service_orders", force: :cascade do |t|
    t.integer "month"
    t.date "date_so"
    t.string "so"
    t.string "so_type"
    t.string "location"
    t.string "equipment"
    t.string "customer_no"
    t.string "customer"
    t.string "key_customer"
    t.string "vendor"
    t.string "vendor_key"
    t.string "type_cargo"
    t.string "commodity"
    t.string "vehicle"
    t.string "name_of_vessel"
    t.string "description"
    t.date "docs_date"
    t.date "payment_due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "branch", default: "tvpl"
    t.datetime "deleted_at"
    t.string "bill_of_lading"
    t.string "contract"
    t.date "end"
    t.date "start"
    t.integer "status", default: 0, null: false
    t.index ["deleted_at"], name: "index_service_orders_on_deleted_at"
  end

  create_table "user_service_orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "service_order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "phone"
    t.string "name"
    t.string "user_no"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendors", force: :cascade do |t|
    t.string "msncc"
    t.string "method"
    t.string "account_no"
    t.string "bank_name"
    t.string "name"
    t.integer "dept", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
  end

end
