class AddColumnFileSoContToFileData < ActiveRecord::Migration[7.1]
  def change
    add_column :file_data, :file_so_cont, :string
  end
end
