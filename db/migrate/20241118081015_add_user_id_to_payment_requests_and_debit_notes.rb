class AddUserIdToPaymentRequestsAndDebitNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_requests, :user_id, :integer
    add_column :payment_requests, :group_id, :integer

    add_column :debit_notes, :user_id, :integer
    add_column :debit_notes, :group_id, :integer
  end
end
