class Bid < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :product
  belongs_to :company
  delegate   :open,   to: :product

  validate  :validate_amount
  validates :amount,      presence: true, numericality: { only_integer: true }

  private

  def validate_amount
    errors[:amount] << ("入札金額が#{open.rate}円単位ではありません")          if min_price % open.rate > 0
    errors[:amount] << ("入札金額が#{product.min_price}円未満になっています")  if min_price < product.min_price
  end
end
