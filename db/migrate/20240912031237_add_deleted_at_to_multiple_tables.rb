class AddDeletedAtToMultipleTables < ActiveRecord::Migration[7.1]
  def change
    add_column :service_orders, :deleted_at, :datetime
    add_index  :service_orders, :deleted_at

    add_column :business_plans, :deleted_at, :datetime
    add_index  :business_plans, :deleted_at

    add_column :debit_notes, :deleted_at, :datetime
    add_index  :debit_notes, :deleted_at

    add_column :payment_requests, :deleted_at, :datetime
    add_index  :payment_requests, :deleted_at

    add_column :results, :deleted_at, :datetime
    add_index  :results, :deleted_at
  end
end
