# frozen_string_literal: true

# == Schema Information
#
# Table name: vendors
#
#  id         :bigint           not null, primary key
#  account_no :string
#  bank_name  :string
#  dept       :integer          default(0)
#  key        :string
#  method     :string
#  msncc      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Vendor < ApplicationRecord
end
