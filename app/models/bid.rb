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

  validate  :validate_amount
  validates :amount,      presence: true, numericality: { only_integer: true }

  scope :successes, -> { order(amount: :desc, sameno: :desc, id: :asc) }

  def self.success_products
    select(&:success?).map(&:product)
  end

  def success?
    success_bid == self ? true : false
  end

  private

  def validate_amount
    errors[:amount] << ("入札金額が#{open.rate}円単位ではありません")          if amount % open.rate > 0
    errors[:amount] << ("入札金額が#{product.min_price}円未満になっています")  if amount < product.min_price
  end
end
