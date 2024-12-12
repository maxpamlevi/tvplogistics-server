# frozen_string_literal: true

class CreatePaymentRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_requests do |t|
      t.string :so

      t.date :payment_date
      t.string :requested_by
      t.string :dept
      t.string :pr_no
      t.string :invoice_no
      t.string :payment_vendor
      t.date :invoice_date
      t.text :description
      t.float :quantity
      t.float :unit_price
      t.float :amount
      t.float :amount_vat
      t.date :docs_date
      t.date :payment_due_date
      t.string :payment_status
      t.string :remark
      t.string :uom
      t.string :allow

      t.integer :service_order_id
      t.timestamps
    end
  end
end
