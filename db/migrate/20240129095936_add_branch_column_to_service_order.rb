class AddBranchColumnToServiceOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :service_orders, :branch, :string, default: 'tvpl'
    add_column :debit_notes, :branch, :string, default: 'tvpl'
    add_column :payment_requests, :branch, :string, default: 'tvpl'
  end
end
