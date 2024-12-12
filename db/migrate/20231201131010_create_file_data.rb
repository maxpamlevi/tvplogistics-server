# frozen_string_literal: true

class CreateFileData < ActiveRecord::Migration[7.1]
  def change
    create_table :file_data do |t|
      t.string :file_internal_id
      t.string :file_external_id
      t.string :file_discharge_id
      t.string :file_load_id
      t.string :file_truck_id
      t.string :file_barge_id

      t.integer :service_order_id, null: false

      t.timestamps
    end
  end
end
