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
    fullopen? ||
    ((carry_in_end_date.to_time..bid_start_at).cover?(Time.now) && Display.check(:search)) ||
    (Time.now > bid_start_at) rescue false
  end

  def bid?
    fullopen? || ((bid_start_at..bid_end_at).cover?(Time.now)) rescue false
  end

  def bid_start?
    fullopen? || (Time.now > bid_start_at) rescue false
  end

  def bid_end?
    fullopen? || (Time.now > bid_end_at )rescue false
  end

  def result_list?
    fullopen? || (Time.now > bid_end_at && Display.check(:result_sum)) rescue false
  end

  def result_sum?
    fullopen? || (Time.now > bid_end_at && Display.check(:result_list)) rescue false
  end

  def entry?
    fullopen? || ((entry_start_date..entry_end_date).cover?(Date.today))rescue false
  end

  def entry_start?
    fullopen? || (Time.now > entry_start_date.to_time) rescue false
  end

  def tax_calc(val)
    (BigDecimal(val.to_s) * BigDecimal((Float(tax) / 100).to_s)).floor
  end

  def tax_total(val)
    val + tax_calc(val)
  end

  def result_sum
    products.listed.includes(:view_success_bid).each do |p|
      next if p.view_success_bid.blank?

      p.update(
        success_bid_id: p.view_success_bid.id,
        bids_count:     p.view_success_bid.count,
        same_count:     p.view_success_bid.same_count,
      )
    end

    self.update(result: true)
  end

  private

  def fullopen?
    Rails.env.staging?
    Rails.env.development? || Rails.env.staging?
  end
end
