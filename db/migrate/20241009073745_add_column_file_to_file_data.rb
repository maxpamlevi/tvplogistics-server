class AddColumnFileToFileData < ActiveRecord::Migration[7.1]
  def change
    add_column :file_data, :file, :string
  end
end
