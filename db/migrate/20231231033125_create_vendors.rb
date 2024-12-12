# frozen_string_literal: true

class CreateVendors < ActiveRecord::Migration[7.1]
  def change
    create_table :vendors do |t|
      t.string :msncc
      t.string :method
      t.string :account_no
      t.string :bank_name
      t.string :name
      t.integer :dept

      t.timestamps
    end
  end
end
