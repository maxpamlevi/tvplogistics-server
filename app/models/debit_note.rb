# frozen_string_literal: true

# == Schema Information
#
# Table name: debit_notes
#
#  id               :bigint           not null, primary key
#  allow            :string
#  amount           :float
#  amount_vat       :float
#  branch           :string           default("tvpl")
#  compensation     :float
#  contract         :string
#  customer         :string
#  date             :date
#  deleted_at       :datetime
#  deposit          :float
#  description      :text
#  payment_date     :date
#  quantity         :float
#  refund           :string
#  so               :string
#  status           :integer          default("listing")
#  unit_price       :float
#  uom              :string
#  vat              :float            default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  group_id         :integer
#  service_order_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_debit_notes_on_deleted_at  (deleted_at)
#
class DebitNote < ApplicationRecord
  acts_as_paranoid
  belongs_to :service_order, optional: true
  enum status: { listing: 0, pending: 1, done: 2 }

  after_save :update_revenue
  before_update :update_amount
  before_update :prevent_update_if_done
  def self.update_customer
    DebitNote.all.each do |d|
      next if d.customer.present? || d.service_order_id.blank?

      d.update_column(:customer, d.service_order.customer)
    end
  end

  private
  def update_amount
    self.amount = quantity.to_f * unit_price.to_f
    self.amount_vat = amount.to_f + amount.to_f * vat.to_f / 100
  end

  def update_revenue
    Result.update_revenue(service_order_id)
  end

  def prevent_update_if_done
    if status_was == 'done'
      errors.add(:status, "Cannot be updated if it is done")
      throw(:abort)
    end
  end
end
