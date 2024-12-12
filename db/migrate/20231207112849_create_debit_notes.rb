# frozen_string_literal: true

class CreateDebitNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :debit_notes do |t|
      t.string :so
      t.string :customer
      t.date :date

      t.text :description
      t.float :quantity
      t.float :unit_price
      t.float :amount
      t.float :amount_vat
      t.float :deposit
      t.date :payment_date
      t.string :uom
      t.string :allow

      t.string :refund

      t.integer :service_order_id

      t.timestamps
    end
  end
end
