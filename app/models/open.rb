class Open < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :products
  has_many :bids, through: :products

  validates :name,                 presence: true
  validates :owner,                presence: true
  validates :entry_start_date,     presence: true
  validates :entry_end_date,       presence: true
  validates :carry_in_start_date,  presence: true
  validates :carry_in_end_date,    presence: true
  validates :preview_start_date,   presence: true
  validates :preview_end_date,     presence: true
  validates :bid_start_at,         presence: true
  validates :bid_end_at,           presence: true
  validates :user_bid_end_at,      presence: true
  validates :carry_out_start_date, presence: true
  validates :carry_out_end_date,   presence: true
  validates :billing_date,         presence: true
  validates :payment_date,         presence: true
  validates :lower_price,          presence: true, numericality: { only_integer: true }
  validates :rate,                 presence: true, numericality: { only_integer: true }
  validates :tax,                  presence: true, numericality: { only_integer: true }

  # 現在開催中の入札会を取得
  scope :now, -> {
    where('entry_start_date <= ?', Time.now).where('carry_out_end_date >= ?', Time.now).order(:id)
  }

  def display?
    ((carry_in_end_date..bid_start_at).cover?(Time.now) && Display.check(:search)) ||
    (Time.now > bid_start_at) rescue false
  end

  def bid?
    (bid_start_at..bid_end_at).cover?(Time.now) rescue false
  end

  def bid_start?
    Time.now > bid_start_at rescue false
  end

  def result_list?
    Time.now > bid_end_at && Display.check(:result_sum) rescue false
  end

  def result_sum?
    Time.now > bid_end_at && Display.check(:result_list) rescue false
  end

  def entry?
    (entry_start_date..entry_end_date).cover?(Time.now) rescue false
  end

  def entry_start?
    Time.now > entry_start_date rescue false
  end

  def tax_calc(val)
    (BigDecimal(val.to_s) * BigDecimal((Float(tax) / 100).to_s)).floor
  end

  def tax_total(val)
    val + tax_calc(val)
  end

  def filename
    name.gsub(/[^0-9A-Za-z]/, "")
  end
end
