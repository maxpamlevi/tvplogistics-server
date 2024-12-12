# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id          :bigint           not null, primary key
#  address     :string
#  customer_no :string
#  dept        :integer          default(0)
#  name        :string
#  tax_no      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Customer < ApplicationRecord
end
