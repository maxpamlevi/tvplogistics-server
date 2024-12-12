# frozen_string_literal: true

# == Schema Information
#
# Table name: business_plans
#
#  id               :bigint           not null, primary key
#  bill_of_lading   :string
#  contract         :string
#  deleted_at       :datetime
#  end              :date
#  start            :date
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  service_order_id :integer          not null
#
# Indexes
#
#  index_business_plans_on_deleted_at  (deleted_at)
#
class BusinessPlan < ApplicationRecord
  acts_as_paranoid
  belongs_to :service_order

  enum status: { done: 1, cancel: 2 }

  # after_save :update_so

  # def update_so
  #   so = ServiceOrder.where(id: self.service_order_id).first.so
  #   self.update_column(:so, so)
  # end
end
