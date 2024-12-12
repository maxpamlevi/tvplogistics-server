# frozen_string_literal: true

class CreateServiceOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :service_orders do |t|
      t.integer :month
      t.date :date_so
      t.string :so

      t.string :type

      t.string :location
      t.string :equipment
      t.string :customer_no
      t.string :customer
      t.string :key_customer
      t.string :vendor
      t.string :vendor_no
      t.string :type_cargo
      t.string :commodity
      t.string :vehicle
      t.string :name_of_vessel
      t.string :description

      t.date :docs_date
      t.date :payment_due_date

      t.timestamps
    end
  end
end
