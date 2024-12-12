class AddColumnVatToDebitNote < ActiveRecord::Migration[7.1]
  def change
    add_column :debit_notes, :vat, :float, default: 0.0
    change_column_default :payment_requests, :vat, 0
  end
end
