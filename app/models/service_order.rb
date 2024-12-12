# frozen_string_literal: true

# == Schema Information
#
# Table name: service_orders
#
#  id               :bigint           not null, primary key
#  bill_of_lading   :string
#  branch           :string           default("tvpl")
#  commodity        :string
#  contract         :string
#  customer         :string
#  customer_no      :string
#  date_so          :date
#  deleted_at       :datetime
#  description      :string
#  docs_date        :date
#  end              :date
#  equipment        :string
#  key_customer     :string
#  location         :string
#  month            :integer
#  name_of_vessel   :string
#  payment_due_date :date
#  so               :string
#  so_type          :string
#  start            :date
#  status           :integer          default("listing"), not null
#  type_cargo       :string
#  vehicle          :string
#  vendor           :string
#  vendor_key       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_service_orders_on_deleted_at  (deleted_at)
#
class ServiceOrder < ApplicationRecord
  acts_as_paranoid
  serialize :vendor, coder: JSON
  serialize :customer, coder: JSON

  enum status: { done: 1, listing: 0 }

  has_many :user_service_orders, dependent: :destroy
  has_many :users, through: :user_service_orders

  has_one :result, dependent: :destroy
  # has_one :business_plan, dependent: :destroy
  has_one :file_data, dependent: :destroy

  has_many :payment_requests, dependent: :destroy
  has_many :debit_notes, dependent: :destroy

  accepts_nested_attributes_for :users

  after_create :create_business_plan
  after_update :after_update_data

  validates :so, presence: true

  def create_business_plan
    Result.create({ service_order_id: id })
  end

  def after_update_data
    return unless saved_change_to_so?

    DebitNote.where(service_order_id: id).update_all(so:)
    PaymentRequest.where(service_order_id: id).update_all(so:)

  end

end
