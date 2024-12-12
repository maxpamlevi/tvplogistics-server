# frozen_string_literal: true

class CreateBusinessPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :business_plans do |t|
      t.string :contract
      t.date :start
      t.date :end
      t.integer :status
      t.string :bill_of_lading
      t.integer :service_order_id, null: false
      t.timestamps
    end
  end
end
