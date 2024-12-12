# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :customer_no
      t.string :name

      t.string :address
      t.string :tax_no
      t.integer :dept

      t.timestamps
    end
  end
end
