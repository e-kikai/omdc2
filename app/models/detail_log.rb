# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint           not null, primary key
#  host       :string           default("")
#  ip         :string           default("")
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string           default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_detail_logs_on_product_id  (product_id)
#  index_detail_logs_on_user_id     (user_id)
#
class DetailLog < ApplicationRecord
  include LinkSource

  belongs_to :user,    required: false
  belongs_to :product, required: true

  before_save :check_robot

  # ROBOTS = /(google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws)/

  private

  # def check_robot
  #   host !~ ROBOTS && ip.present?
  # end
end
