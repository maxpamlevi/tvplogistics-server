class MergeBusinessPlansIntoServiceOrders < ActiveRecord::Migration[7.1]
  def up
    # Add new columns to the service_orders table
    add_column :service_orders, :bill_of_lading, :string
    add_column :service_orders, :contract, :string
    add_column :service_orders, :end, :date
    add_column :service_orders, :start, :date
    add_column :service_orders, :status, :integer, default: 0, null: false


    # Migrate data from business_plans to service_orders
    execute <<-SQL.squish
      UPDATE service_orders
      SET
        bill_of_lading = business_plans.bill_of_lading,
        contract = business_plans.contract,
        deleted_at = business_plans.deleted_at,
        "end" = business_plans.end,
        "start" = business_plans.start,
        status = COALESCE(business_plans.status, 0)
      FROM business_plans
      WHERE service_orders.id = business_plans.service_order_id
    SQL

    # Remove the business_plans table
    # drop_table :business_plans
  end

  def down
    # Recreate the business_plans table
    create_table :business_plans do |t|
      t.string :bill_of_lading
      t.string :contract
      t.datetime :deleted_at
      t.date :end
      t.date :start
      t.integer :status
      t.integer :service_order_id, null: false

      t.timestamps null: false
    end

    # Migrate data back from service_orders to business_plans
    execute <<-SQL.squish
      INSERT INTO business_plans (bill_of_lading, contract, deleted_at, end, start, status, service_order_id, created_at, updated_at)
      SELECT bill_of_lading, contract, deleted_at, "end", "start", status, id AS service_order_id, created_at, updated_at
      FROM service_orders
    SQL

    # Remove columns from service_orders
    # remove_column :service_orders, :bill_of_lading
    # remove_column :service_orders, :contract
    # remove_column :service_orders, :end
    # remove_column :service_orders, :start
    # remove_column :service_orders, :status
  end
end