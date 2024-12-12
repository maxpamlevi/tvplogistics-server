class RemoveNilAndEmptyFromVendorInServiceOrders < ActiveRecord::Migration[7.1]
  def up
    ServiceOrder.find_each do |service_order|
      if service_order.vendor.is_a?(Array)
        service_order.vendor.reject! { |v| v.nil? || v.empty? }
        service_order.save!
      end
    end
  end
end

