class AddColumnSoBkToFileData < ActiveRecord::Migration[7.1]
  def change
    add_column :file_data, :file_so_bk, :string

  end
end
