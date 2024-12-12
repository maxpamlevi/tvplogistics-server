class AddStatusColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_requests, :status, :integer, default: 0

    add_column :debit_notes, :status, :integer, default: 0

    PaymentRequest.where(allow: 2).update_all(status: 2)
    PaymentRequest.where(allow: 1).update_all(status: 1)
    PaymentRequest.where(allow: [nil, 0]).update_all(status: 0)

    DebitNote.where(allow: 2).update_all(status: 2)
    DebitNote.where(allow: 1).update_all(status: 1)
    DebitNote.where(allow: [nil, 0]).update_all(status: 0)
  end
end
