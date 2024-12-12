# frozen_string_literal: true

# == Schema Information
#
# Table name: results
#
#  id               :bigint           not null, primary key
#  cost             :float            default(0.0)
#  deleted_at       :datetime
#  discharge        :float            default(0.0)
#  external_wh      :float            default(0.0)
#  grand_total      :float            default(0.0)
#  internal_wh      :float            default(0.0)
#  profit           :float            default(0.0)
#  revenue          :float            default(0.0)
#  total_wh         :float            default(0.0)
#  tvpl_barge       :float            default(0.0)
#  tvpl_load        :float            default(0.0)
#  tvpl_truck       :float            default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  service_order_id :integer          not null
#
# Indexes
#
#  index_results_on_deleted_at  (deleted_at)
#
class Result < ApplicationRecord
  acts_as_paranoid
  belongs_to :service_order

  after_update :update_grand_total

  DATA = { d: 'discharge', l: 'tvpl_load', b: 'tvpl_barge', t: 'tvpl_truck', i: 'internal_wh', e: 'external_wh' }.freeze

  def self.update_cost(id)
    result = Result.find_by(service_order_id: id)
    return if result.blank?
    value = PaymentRequest.where(service_order_id: id).sum(:amount_vat)
    result.update(cost: value)
    update_profit(result)
  end

  def self.update_revenue(id)
    result = Result.find_by(service_order_id: id)
    return if result.blank?
    value = DebitNote.where(service_order_id: id).sum(:amount_vat)
    result.update(revenue: value)
    update_profit(result)
  end

  def self.update_profit(rel)
    return if rel.revenue.blank? || rel.cost.blank?

    profit = rel.revenue - rel.cost
    rel.update(profit:)
  end

  def update_grand_total
    grand_total = tvpl_barge + tvpl_truck + tvpl_load + internal_wh + external_wh + discharge
    update_column(:grand_total, grand_total)
  end

end
