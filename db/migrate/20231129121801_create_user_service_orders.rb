# frozen_string_literal: true

class CreateUserServiceOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :user_service_orders do |t|
      t.integer :user_id, null: false
      t.integer :service_order_id, null: false
      t.timestamps
    end
  end
end
