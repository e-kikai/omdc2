# == Schema Information
#
# Table name: requests
#
#  id                :bigint           not null, primary key
#  amount            :integer
#  bided_at          :datetime
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :bigint
#  product_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_requests_on_company_id         (company_id)
#  index_requests_on_product_id         (product_id)
#  index_requests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_requests_on_user_id            (user_id)
#
class Request < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user,    required: true
  belongs_to :product, required: true
  belongs_to :company, required: true
  delegate   :open,    to: :product

  has_one    :genre,       through: :product
  has_one    :large_genre, through: :genre
  has_one    :xl_genre,    through: :large_genre

  validates :amount,       presence: true, numericality: { only_integer: true }
  validate  :validate_amount

  def check_5time
    amount >= product.min_price * 5 ? amount : false
  end

  private

  def validate_amount
    errors[:amount] << ("が#{open.rate.to_s(:delimited)}円単位ではありません")          if amount.to_i % open.rate > 0
    errors[:amount] << ("が#{product.min_price.to_s(:delimited)}円未満になっています")  if amount.to_i < product.min_price
  end
end
