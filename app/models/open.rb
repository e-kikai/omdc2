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

  # 現在の入札会の状態を取得
  def status
    case Date.now
    when entry_start_date..entry_end_date;         :entry
    when carry_in_start_date..carry_in_end_date;   :carry_in
    when carry_in_end_date..bid_start_at;          :list
    when bid_start_at..bid_end_at;                 :bid
    when carry_out_start_date..carry_out_end_date; :carry_out
    else                                           :none
    end
  end

  def display?
    if    [:bid, :carry_out].include? status; true
    elsif status == :list && display == true; true
    else;                                     false
    end
  end

  # def bid?
  #   Date.now === bid_start_at..bid_end_at ? true : false
  # end

  def tax_calc(val)
    (BigDecimal(val.to_s) * BigDecimal((Float(tax) / 100).to_s)).floor
  end

  def tax_total(val)
    val + tax_calc(val)
  end
end
