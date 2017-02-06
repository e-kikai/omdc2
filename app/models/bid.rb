class Bid < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :product, required: true
  belongs_to :company, required: true
  delegate   :open,   to: :product

  has_one    :genre,       through: :product
  has_one    :large_genre, through: :genre
  has_one    :xl_genre,    through: :large_genre

  has_one    :success_bid, -> { successes }, class_name: Bid, through: :product

  validates :amount,      presence: true, numericality: { only_integer: true }
  validate  :validate_amount

  scope :successes, -> { order(amount: :desc, sameno: :desc, id: :asc) }

  def self.success_products
    select(&:success?).map(&:product)
  end

  def success?
    success_bid == self ? true : false
  end

  def check_5time
    amount >= product.min_price * 5 ? amount : false
  end

  private

  def validate_amount
    errors[:amount] << ("が#{open.rate.to_s(:delimited)}円単位ではありません")          if amount.to_i % open.rate > 0
    errors[:amount] << ("が#{product.min_price.to_s(:delimited)}円未満になっています")  if amount.to_i < product.min_price
  end
end
