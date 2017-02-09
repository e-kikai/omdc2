class Product < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :open
  belongs_to :company, required: true
  belongs_to :genre
  has_one    :large_genre, through: :genre
  has_one    :xl_genre,    through: :large_genre
  belongs_to :area

  # has_many :bids,           -> { successes }
  has_many :bids
  has_one  :success_bid,    -> { successes }, class_name: Bid

  has_many :product_images, -> { order(:order_no, :id) }
  has_one  :top_image,      -> { order(:order_no, :id) }, class_name: ProductImage

  enum display: { "一般出品" => 0, "常設コマ" => 10, "単品預り" => 20, "店頭出品" => 30 }

  validates :name,      presence: true
  validates :min_price, presence: true
  validates :min_price, numericality: { only_integer: true }

  validate  :check_min_price_to_open

  before_create :set_app_no
  before_save   :reform_youtube

  scope :with_keywords, -> keywords {
    if keywords.present?
      columns = [:name, :maker, :model, :year, :spec, :condition]
      where(keywords.split(/[[:space:]]/).reject(&:empty?).map {|keyword|
        columns.map { |a| arel_table[a].matches("%#{keyword}%") }.inject(:or)
      }.inject(:and))
    end
  }

  scope :listed, -> {
    where.not(list_no: nil)
  }

  scope :max_list_no, -> {
    maximum(:list_no) || 0
  }

  def self.ml_get_genre(product)
    workspaces = "42c03c07608247ef802a8ff6fce5b577"
    services   = "7bde3c5e52ac486e8cd3ea0b8d0f3c4f"
    api_key    = "O4R4QencOUtm3/i/SOseIIHYcmdLVIvIeZYI2JKOinbjEnlmrOXE6JULzHgTBvQlqA0dvh3Wu4+4B3+GMXvKjg=="

    url = "https://ussouthcentral.services.azureml.net/workspaces/#{workspaces}/services/#{services}/score"

    req_params = {
      "Id"       => "score00001",
      "Instance" => {
        "FeatureVector" =>  {
          "list_no" => 1,
          "name"    => product[:name].presence || "((不明))",
          "maker"   => product[:maker].presence || "((不明))",
          "model"   => product[:model].presence || "((不明))",
          "model2"  => product[:model].to_s.gsub(/\s*/, " ").gsub(/\s.*$/, "").upcase.gsub(/[^0-9A-Z]/, "").presence || "((不明))",
          "price"   => product[:min_price].presence || 0,
        },
        "GlobalParameters" => {}
      }
    }

    req_header = {
      "Authorization"  => "Bearer #{api_key}",
      "Content-Type"   => "application/json"
    }

    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port.to_s)
    https.use_ssl = true
    # https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.path, req_header)
    req.body = req_params.to_json
    res = https.request(req)

    if res.code == "200"
      res_hash = JSON.parse(res.body)
      res_hash[7].blank? ? res_hash[6].gsub(/\s.*$/, "") : res_hash[7]
    else
      "error : #{res}"
    end
  rescue => e
    "error : #{e.message}"
  end

  def self.search_genre(product)
    products = Product.where.not(genre_id: 390).order(id: :desc)
    model_reg = product[:model].gsub(/[^0-9a-zA-Z]+/, "%")

    if product[:name].blank?
      # 0. 機械名がなければ、処理をしない
      "error : 機械名を入力して下さい"
    elsif genre = Genre.where.not(id: 390).order(id: :desc).find_by(name: product[:name])
      # 1. 機械名 = ジャンル名の場合
      genre.id
    elsif model_reg.present? && pr = products.where(name: product[:name]).where(" products.model ILIKE ? ", "#{model_reg}%").first
      # 2. 同じname, modelのもの
      pr.genre_id
    elsif pr = products.find_by(name: product[:name])
      # 3. 同じnameのもの
      pr.genre_id
    elsif pr = products.where(" products.name ILIKE ? ", "#{product[:name]}%").first
      # 4. nameをILIKE検索(前方一致)
      pr.genre_id
    elsif pr = products.where(" products.name ILIKE ? ", "%#{product[:name]}%").first
      # 5. nameをILIKE検索(中間一致)
      pr.genre_id
    elsif model_reg.present? && pr = products.where(" products.model ILIKE ? ", "#{model_reg}%").first
      # 6. modelをILIKE検索(前方一致)
      pr.genre_id
    elsif model_reg.present? && pr = products.where(" products.model ILIKE ? ", "%#{model_reg}%").first
      # 7. modelをILIKE検索(中間一致)
      pr.genre_id
    else
      # Product.ml_get_genre(product)
      390
    end
  rescue => e
    "error : #{e.message}"
  end

  def set_genre
    self.genre_id = Product.search_genre(self)
    self
  end

  def area_name
    case
    when tento?;        company.name
    when area.present?; area.name
    else;               "-"
    end
  end

  def tento?
    display == "店頭出品" ? true : false
  end

  def bid?
    success_bid.present? ? true : false
  end

  def success_price
    bid? ? success_bid.amount : 0
  end

  def deme
    bid? ? success_price - min_price : 0
  end

  def deme_h
    deme / 2
  end

  def hanbai_fee_per
    if bid?
      per = case min_price
      when 0..1_000_000;         10
      when 1_000_000..2_000_000; 8
      when 2_000_000..3_000_000; 7
      else;                      5
      end
    else
      nil
    end
  end

  def hanbai_fee
    hanbai_fee_per.present? ? min_price * hanbai_fee_per / 100 : 0
  end

  def kumiai_fee_per
    if bid?
      per = case min_price
      when 0..100_000;         5
      when 100_000..1_000_000; 4
      else;                    3
      end
    else
      nil
    end
  end

  def kumiai_fee
    kumiai_fee_per.present? ? min_price * kumiai_fee_per / 100 : 0
  end

  def shuppin_fee_per
    if bid? || display != "一般出品"
      nil
    else
      per = case min_price
      when 0..100_000;         4
      when 100_000..1_500_000; 2
      else;                    nil
      end
    end
  end

  def shuppin_fee
    if bid? || display != "一般出品"
      0
    else
      shuppin_fee_per.present? ? min_price * shuppin_fee_per / 100 : 30_000
    end
  end

  def shiharai
    bid? ? success_bid.amount - deme_h - kumiai_fee - hanbai_fee : -shuppin_fee
  end

  def seikyu
    bid? ? success_bid.amount - deme_h - hanbai_fee : 0
  end

  def self.import_conf(file)
    res = []
    CSV.foreach(file.path, { :headers => true, encoding: Encoding::SJIS }) do |row|
      product = new(
        name:      row[0],
        maker:     row[1],
        model:     row[2],
        hitoyama:  row[3].present?,
        min_price: row[4],
        year:      row[5],
        spec:      row[6],
        condition: row[7],
        comment:   row[8],
        display:   row[9] || 0,
        youtube:   row[10],
      )
      product.set_genre
      product.valid?
      res << product
    end

    res
 end

 def self.import(products)
   products.each { |p| create(p) }
 end

  private

  def check_min_price_to_open
    errors[:min_price] << ("が#{open.rate.to_s(:delimited)}円単位ではありません")         if min_price.to_i % open.rate > 0
    errors[:min_price] << ("が#{open.lower_price.to_s(:delimited)}円未満になっています")  if min_price.to_i < open.lower_price
  end

  def set_app_no
    last_no = self.open.products.where(company_id: company_id).where.not(app_no: nil).order(:app_no).last.try(:app_no) || 0
    self.app_no = last_no + 1
  end

  def reform_youtube
    self.youtube = case self.youtube
    when /watch\?v\=([a-zA-Z0-9-+]+)/;  $1
    when /youtu\.be\/([a-zA-Z0-9-+]+)/; $1
    else self.youtube
    end
  end
end