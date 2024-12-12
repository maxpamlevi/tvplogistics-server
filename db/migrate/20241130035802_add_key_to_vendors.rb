class AddKeyToVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :key, :string
    rename_column :service_orders, :vendor_no, :vendor_key
  end
end
