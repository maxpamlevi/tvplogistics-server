# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_requests
#
#  id               :bigint           not null, primary key
#  allow            :string
#  amount           :float
#  amount_vat       :float
#  branch           :string           default("tvpl")
#  deleted_at       :datetime
#  dept             :string
#  description      :text
#  docs_date        :date
#  invoice_date     :date
#  invoice_no       :string
#  payment_date     :date
#  payment_due_date :date
#  payment_status   :string
#  payment_vendor   :string
#  pr_no            :string
#  quantity         :float
#  remark           :string
#  requested_by     :string
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
#  index_payment_requests_on_deleted_at  (deleted_at)
#
class PaymentRequest < ApplicationRecord
  acts_as_paranoid
  belongs_to :service_order, optional: true
  enum status: { listing: 0, pending: 1, done: 2 }

  after_save :update_cost
  before_update :update_amount
  # before_create :set_invoice_no
  before_update :prevent_update_if_done

  def self.update_pay_due_date(pay)
    ids = pay.pluck('id')
    PaymentRequest.where(id: ids).each do |pay|
      vendor = Vendor.find_by(name: pay.payment_vendor)
      return if pay.docs_date.blank? || vendor.blank? || pay.payment_due_date.present?

      payment_due_date = pay.docs_date + vendor.dept.days
      pay.update_column(:payment_due_date, payment_due_date)
    end
  end

  private
  def update_cost
    Result.update_cost(service_order_id)
  end
  def update_amount
    self.amount = quantity.to_f * unit_price.to_f
    self.amount_vat = amount.to_f + amount.to_f * vat.to_f / 100
  end
  def set_invoice_no
    return if status == :done || invoice_no.present?

    max_invoice_no = PaymentRequest.where(payment_vendor: payment_vendor).maximum(:invoice_no).to_i
    self.invoice_no = (max_invoice_no + 1).to_s
  end

  def prevent_update_if_done
    if status_was == 'done'
      errors.add(:status, "Cannot be updated if it is done")
      throw(:abort)
    end
  end

end
