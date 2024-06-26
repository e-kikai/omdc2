# == Schema Information
#
# Table name: opens
#
#  id                   :integer          not null, primary key
#  addr                 :text             default("東大阪市本庄中2-2-38"), not null
#  bid_end_at           :datetime         not null
#  bid_start_at         :datetime         not null
#  billing_date         :date             not null
#  carry_in_end_date    :date             not null
#  carry_in_start_date  :date             not null
#  carry_out_end_date   :date             not null
#  carry_out_start_date :date             not null
#  entry_end_date       :date             not null
#  entry_start_date     :date             not null
#  fax                  :text             default("06-6747-7529"), not null
#  lower_price          :integer          default(20000)
#  name                 :string           default(""), not null
#  owner                :string           default("大阪機械卸業団地協同組合"), not null
#  payment_date         :date             not null
#  place                :text             default("大阪機械卸業団地協同組合 共同展示場"), not null
#  preview_end_date     :date             not null
#  preview_start_date   :date             not null
#  product_rate         :integer          default(1000), not null
#  rate                 :integer          default(1000)
#  result               :boolean          default(FALSE), not null
#  soft_destroyed_at    :datetime
#  tax                  :integer          default(8)
#  tel                  :text             default("06-6747-7528"), not null
#  user_bid_end_at      :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_opens_on_soft_destroyed_at  (soft_destroyed_at)
#
class Open < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :products
  has_many :bids,     through: :products
  has_many :requests, through: :products

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
  validates :product_rate,         presence: true, numericality: { only_integer: true }
  validates :tax,                  presence: true, numericality: { only_integer: true }

  VECTOR_CACHE = "vector"

  REGISTRATION_NUMBER = "T1122005000318"

  # 現在開催中の入札会を取得
  scope :now, -> {
    where('entry_start_date <= ?', Time.now).where('carry_out_end_date >= ?', Time.now).order(:id)
  }

  scope :next, -> {
    where('entry_start_date > ?', Time.now).order(:entry_start_date)
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

  # 画像特徴ベクトル一括変換・キャッシュ
  # @return true
  def process_and_cache_all
    bucket  = Product.s3_bucket # S3バケット取得

    ### キャッシュ取得 ###
    vectors = vectors_cache

    ### ベクトルを検索キャッシュ保存  ###
    c = 0
    products.includes(:product_images).each do |pr|
      image = pr.product_images.first

     if image.blank?
       # 画像がない場合、パス
       logger.debug "#{pr.id} :: no image!"
       next
     elsif vectors[pr.id].present? && vectors[pr.id] != Product::ZERO_NARRAY
       # 既にキャッシュされている場合、パス
       logger.debug "#{pr.id} :: OK exsist"
       next
     end

     s3_vector_path = "#{Product::S3_VECTORS_PATH}/vector_#{pr.id}.npy"

      ### ベクトルファイルがない場合、変換 ###
      unless bucket.object(s3_vector_path).exists?
        pr.process_vector
        logger.debug "#{pr.id} :: <<< process >>>"
      end

      # 変換済みのベクトルファイルをキャッシュへ
      str = bucket.object(s3_vector_path).get.body.read
      vectors[pr.id] = Npy.load_string(str) rescue Product::ZERO_NARRAY
      logger.debug "#{pr.id} :: store"

      ### キャッシュに保存(途中経過) ###
      c += 1
      if c % 100 == 0
        Rails.cache.write(cache_filename, vectors)
        logger.debug "--- cache save ---"
      end
    end

    ### キャッシュに保存 ###
    Rails.cache.write(cache_filename, vectors)
    logger.debug "--- cache save ---"
  end

  # 入札会ごとのキャッシュのファイル名を取得
  # @return ベクトルキャッシュファイル名
  def cache_filename
    "#{VECTOR_CACHE}_open_#{self.id}"
  end

  # ベクトルキャッシュにアクセス
  # @return PStore ベクトルキャッシュ
  def vectors_cache
    # PStore.new("/tmp/foo/#{cache_filename}")
    Rails.cache.read(cache_filename) || {}
  end

  # 登録番号を出力(とりあえずはハードコーディング)
  def registration_number
    REGISTRATION_NUMBER
  end

  private

  def fullopen?
    Rails.env.staging?
    Rails.env.development? || Rails.env.staging?
  end
end
