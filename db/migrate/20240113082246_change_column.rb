# frozen_string_literal: true

class ChangeColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :service_orders, :type, :so_type
    add_column :file_data, :file_so_load, :string
    add_column :file_data, :file_so_disc, :string
  end
end
