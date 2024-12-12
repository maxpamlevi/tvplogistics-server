# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[7.1]
  def change
    create_table :results do |t|
      t.float :tvpl_load, default: 0
      t.float :discharge, default: 0
      t.float :tvpl_truck, default: 0
      t.float :tvpl_barge, default: 0
      t.float :internal_wh, default: 0
      t.float :external_wh, default: 0

      t.float :total_wh, default: 0

      t.float :grand_total, default: 0
      t.float :revenue, default: 0
      t.float :cost, default: 0
      t.float :profit, default: 0

      t.integer :service_order_id, null: false
      t.timestamps
    end
  end
end
