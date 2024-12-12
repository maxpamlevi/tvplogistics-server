# frozen_string_literal: true

# == Schema Information
#
# Table name: user_service_orders
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  service_order_id :integer          not null
#  user_id          :integer          not null
#
class UserServiceOrder < ApplicationRecord
  belongs_to :user
  belongs_to :service_order
end
