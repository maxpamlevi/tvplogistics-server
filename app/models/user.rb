# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  name                   :string
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("staff")
#  sign_in_count          :integer          default(0), not null
#  user_no                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  has_many :user_service_orders

  has_many :service_orders, through: :user_service_orders

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { staff: 0, accountant: 1, settlement: 3, admin: 4 }

  def self.create_user
    # User.create({ email: 'sales@tvplogistics.com', name: 'Vi', password: '1454010224@Vi', role: :admin })
    # User.create({ email: 'cs1@tvplogistics.com', name: 'Như', password: '123123', role: :settlement })
    # User.create({ email: 'cs2@tvplogistics.com', name: 'Khanh', password: '123123' })
    # User.create({ email: 'cs4@tvplogistics.com', name: 'Thảo', password: '123123' })
    # User.create({ email: 'sale1@tvplogistics.com', name: 'Vy', password: 'Tvplogistics@2024@' })
    # User.create({ email: 'staff1@gmail.com', name: 'Staff', password: '123123' })
    # User.create({ email: 'khangiuh6@gmail.com', name: 'Khang', password: '123123', role: :admin })
    # User.create({ email: 'account@tvplogistics.com', name: 'Linh', password: 'Tvplogistics@2023', role: :accountant })
    # User.create({ email: 'ketoancongtytvpl@gmail.com', name: 'Thơ', password: 'Tvplogistics@2023', role: :accountant })
    # User.create({ email: 'accounting@tvplogistics.com', name: 'Bình', password: 'Tvplogistics@2024', role: :accountant })
    # User.create({ email: 'cs3@tvplogistics.com', name: 'Huy', password: 'Tvplogistics@2024cs3', role: :staff })
    # User.create({ email: 'cs1@tvplogistics.com', name: 'Hieu', password: 'tvpl@2024', role: :staff })
  end
end
