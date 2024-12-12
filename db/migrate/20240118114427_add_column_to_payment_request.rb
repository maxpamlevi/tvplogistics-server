class AddColumnToPaymentRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_requests, :vat, :float, default: 1.08
  end
end
