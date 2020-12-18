# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  accessory         :string
#  app_no            :integer
#  bids_count        :integer          default(0)
#  carryout_at       :datetime
#  comment           :text
#  condition         :text
#  display           :integer          default("一般出品"), not null
#  hitoyama          :boolean          default(FALSE)
#  list_no           :integer
#  maker             :string
#  min_price         :integer
#  model             :string
#  name              :string
#  pdfs              :string
#  same_count        :integer          default(0)
#  soft_destroyed_at :datetime
#  spec              :string
#  year              :string
#  youtube           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  area_id           :integer
#  company_id        :integer          not null
#  genre_id          :integer          default(390), not null
#  open_id           :integer          not null
#  success_bid_id    :integer
#
# Indexes
#
#  index_products_on_company_id         (company_id)
#  index_products_on_open_id            (open_id)
#  index_products_on_soft_destroyed_at  (soft_destroyed_at)
#
class Product < ApplicationRecord
  require "open3"

  soft_deletable
  default_scope { without_soft_destroyed }

  # 画像特徴ベクトル関連
  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"
  S3_VECTORS_PATH = "vectors"
  ZERO_NARRAY  =  Numo::SFloat.zeros(1)
  VECTOR_CACHE = "vector"

  VECTORS_LIMIT   = 30

  belongs_to :open,    required: true
  belongs_to :company, required: true
  belongs_to :genre,   required: true
  has_one    :large_genre, through: :genre
  has_one    :xl_genre,    through: :large_genre
  belongs_to :area

  has_many :bids
  has_many :requests
  # has_one  :success_bid,     -> { success }, class_name: "Bid"
  # has_one :success_bid, class_name: "ViewSuccessBid"
  has_one :view_success_bid
  belongs_to :success_bid, class_name: "Bid", foreign_key: :success_bid_id

  # has_one  :bid_sums,        -> { sums }, class_name: "Bid"
  has_one  :success_company, through: :success_bid, source: :company, class_name: "Company"

  has_many :product_images, -> { order(:order_no, :id) }
  has_one  :top_image,      -> { order(:order_no, :id) }, class_name: "ProductImage"
  has_many :detail_logs

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

  scope :bids_sums, -> {
    joins("LEFT JOIN (#{Bid.sums.to_sql}) bs ON bs.product_id = products.id").select("*, bids_count, bids_max_amount")
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
    products = Product.unscope(where: [:company_id, :open_id]).where.not(genre_id: 390).order(id: :desc)

    name      = product[:name].to_s.normalize_charwidth.strip
    model_reg = product[:model].to_s.normalize_charwidth.strip.gsub(/[^0-9a-zA-Z]+/, "%")

    if product[:name].blank?
      # 0. 機械名がなければ、処理をしない
      "error : 機械名を入力して下さい"
    elsif genre = Genre.where.not(id: 390).order(id: :desc).find_by(name: name)
      # 1. 機械名 = ジャンル名の場合
      genre.id
    elsif model_reg.present? && pr = products.where(name: name).where(" products.model ILIKE ? ", "#{model_reg}%").first
      # 2. 同じname, modelのもの
      pr.genre_id
    elsif pr = products.find_by(name: name)
      # 3. 同じnameのもの
      pr.genre_id
    elsif pr = products.where(" products.name ILIKE ? ", "#{name}%").first
      # 4. nameをILIKE検索(前方一致)
      pr.genre_id
    elsif pr = products.where(" products.name ILIKE ? ", "%#{name}%").first
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
    raise "error : #{e.message}"
  end

  def set_genre
    self.genre_id = Product.search_genre(self)
    self
  end

  def set_display(string)
    self.display = Product.displays.first[1]
    Product.displays.each do |k, v|
      if k =~ /#{string}/
        self.display = v
        break
      end
    end
  end

  def area_name
    case
    when tento?;        company.name_remove_kabu
    when area.present?; area.name
    else;               "-"
    end
  end

  def tento?
    display == "店頭出品" ? true : false
  end

  def bid?
    if new_record?
      bids.first.present? ? true : false
    else
      success_bid.present? ? true : false
    end
  end

  def success_price
    bid? ? success_bid.amount : 0
  end

  def deme
    if new_record?
      bids.first.amount - min_price
    else
      bid? ? success_price - min_price : 0
    end
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
    if !new_record? && (bid? || display != "一般出品")
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
    if !new_record? && (bid? || display != "一般出品")
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
      product = find_or_initialize_by(app_no: row[0])

      product.attributes =  {
        name:      row[1],
        maker:     row[2],
        model:     row[3],
        hitoyama:  row[4].present?,
        min_price: row[5],
        year:      row[6],
        spec:      row[7],
        condition: row[8],
        comment:   row[9],
        youtube:   row[11],
        soft_destroyed_at: row[12].present? ? Time.now : nil,
      }

      product.set_display(row[10])
      # product.set_genre
      product.set_genre if product.genre_id == 390

      product.valid?
      res << product
    end

    res
  end

  def self.import(products)
    products.each do |p|
      find_or_initialize_by(app_no: p[:app_no]).update!(p)
    end
  end

  def self.import_conf_by_system(file)
    res = []
    CSV.foreach(file.path, { :headers => true, encoding: Encoding::SJIS }) do |row|
      next if row[0].blank?
      next unless company = Company.find_by(no: row[0])
      product = company.products.find_or_initialize_by(app_no: row[1])

      product.attributes =  {
        list_no:   row[2],
        name:      row[3],
        maker:     row[4],
        model:     row[5],
        hitoyama:  row[6].present?,
        min_price: row[7],
        year:      row[8],
        spec:      row[9],
        condition: row[10],
        comment:   row[11],
        youtube:   row[13],
        soft_destroyed_at: row[14].present? ? Time.now : nil,
      }

      product.set_display(row[12])
      product.set_genre if product.genre_id == 390

      product.valid?
      res << product
    end

    res
  end

  ### トップ画像の有無 ###
  def top_image?
    product_images.first.present?
  end


  ### この商品のベクトルを取得 ###
  def get_vector
    return nil unless top_image? # 画像の有無チェック

    vectors = Rails.cache.read(VECTOR_CACHE) || {} # キャッシュからベクトル群を取得
    bucket  = Product.s3_bucket # S3バケット取得

    ### ターゲットベクトル取得 ###
    if vectors[id].present? # キャッシュからベクトル取得
      vectors[id]
    elsif bucket.object("#{S3_VECTORS_PATH}/vector_#{id}.npy").exists? # アップロードファイルからベクトル取得
      str = bucket.object("#{S3_VECTORS_PATH}/vector_#{id}.npy").get.body.read
      Npy.load_string(str)
    else # ない場合
      nil
    end
  end

  ### 商品から画像特徴ベクトルソート(全件からソートで検索) ###
  def self.image_vector_sort(product_id, limit=Product::VECTORS_LIMIT, page=1, mine=false)
    target = Product.find(product_id).get_vector

    self.image_vector_search(target, limit, page, mine)
  end

  ### 画像ファイルから画像特徴ベクトルソート ###
  def self.image_vector_sort_by_file(image, limit=Product::VECTORS_LIMIT)

    ### 画像ファイルからベクトルを取得 ###
    target = process_vector_by_file(image)

    self.image_vector_search(target, limit)
  end

  ### 画像特徴ベクトル検索処理 ###
  def self.image_vector_search(target, limit=nil, page=1, mine=false)
    return self.none if target.nil?

    ### ベクトル郡取得 ###
    vectors = Rails.cache.read(VECTOR_CACHE) || {} # キャッシュからベクトル群を取得
    bucket = Product.s3_bucket # S3バケット取得
    update_flag = false

    ### 各ベクトル比較 ###
    pids = self.reorder(:id).pluck(:id).uniq # 検索対象(出品中)の商品ID取得

    logger.debug pids.count

    sorts = pids.map do |pid|
      logger.debug("pid : #{pid}")

      ### ベクトルの取得 ###
      pr_narray = if vectors[pid].present? && vectors[pid] != ZERO_NARRAY # 既存
        vectors[pid]
      else # 新規(ファイルからベクトル取得して追加)
        logger.debug("get by file :: pid : #{pid}")

        update_flag = true
        vectors[pid] = if bucket.object("#{S3_VECTORS_PATH}/vector_#{pid}.npy").exists?

          str = bucket.object("#{S3_VECTORS_PATH}/vector_#{pid}.npy").get.body.read
          Npy.load_string(str) rescue ZERO_NARRAY
        else
          ZERO_NARRAY
        end

        vectors[pid]
      end

      # ベクトル比較
      if pr_narray == ZERO_NARRAY || pr_narray.nil? # ベクトルなし
        nil
      else
        sub = pr_narray - target
        res = (sub * sub).sum

        (res > 0 || mine == true) ? [pid, res]  : nil
      end
    end.compact.sort_by { |v| v[1] }

    ### 件数フィルタリング ###
    limit = limit.to_i
    page = page.to_i
    page = 1 if page < 1

    sorts = sorts.slice(limit * (page - 1), limit) if limit > 0

    sorts = sorts.to_h

    # ベクトルキャシュ更新
    Rails.cache.write(VECTOR_CACHE, vectors) if update_flag == true

    # 結果を返す
    where(id: sorts.keys).sort_by { |pr| sorts[pr.id] }
  end

  ### 商品画像から画像特徴ベクトル抽出・バケット保存 ###
  def process_vector
    logger.debug "*** 1 : #{id}"

    bucket = Product.s3_bucket # S3バケット取得
    vector_key = "#{S3_VECTORS_PATH}/vector_#{id}.npy" # 保存ベクトルファイル名
    image = product_images.first

    if image.blank?  # 画像の有無チェック
      errors.add(:base, '商品に画像が登録されていません') and return false
    elsif bucket.object(vector_key).exists? # ベクトルファイルの存否を確認
      errors.add(:base, 'ベクトルファイルがすでに存在します') and return false
    end

    logger.debug "*** 2 : #{vector_key}"

    filename    = image.image_identifier
    image_id    = image.id
    image_key   = "uploads/product_image/image/#{image_id}/#{filename}"

    image_path  = "#{UTILS_PATH}/static/img/#{filename}"
    vector_path = "#{VECTORS_PATH}/#{filename}.npy"

    logger.debug "*** 3 : get #{image_key}"

    bucket.object(image_key).download_file(image_path) # S3より画像ファイルの取得

    ### プロセス ###
    Product.process_vector_core(image_path)

    logger.debug "*** 5 : process #{vector_path}"

    ### バケット保存 ###
    bucket.object(vector_key).upload_file(vector_path) # ベクトルファイルアップロード

    logger.debug "*** 6 : upload"

    ### 不要になった画像ファイル、ベクトルファイルの削除
    File.delete(vector_path, image_path)

    logger.debug "*** 7 : delete"

    self
  rescue => e
    logger.debug "*** X : rescue"
    logger.debug e
  end

  private

  def check_min_price_to_open
    # errors[:min_price] << ("が#{open.rate.to_s(:delimited)}円単位ではありません")         if min_price.to_i % open.rate > 0
    errors[:min_price] << ("が#{open.product_rate.to_s(:delimited)}円単位ではありません") if min_price.to_i % open.product_rate > 0
    errors[:min_price] << ("が#{open.lower_price.to_s(:delimited)}円未満になっています")  if min_price.to_i < open.lower_price
  end

  def set_app_no
    # last_no = self.open.products.where(company_id: company_id).where.not(app_no: nil).order(:app_no).last.try(:app_no) || 0
    last_no = self.open.products.where(company_id: company_id).maximum(:app_no) || 0
    self.app_no = last_no + 1
  end

  def reform_youtube
    self.youtube = case self.youtube
    when /watch\?v\=([a-zA-Z0-9\-+]+)/;  $1
    when /youtu\.be\/([a-zA-Z0-9\-+]+)/; $1
    else self.youtube
    end
  end



  ### アップロードされたファイルから画像特徴ベクトルを抽出 ###
  def self.process_vector_by_file(target)
    image_path      = target.path
    tmp_img_path    = "#{VECTORS_PATH}/#{target.original_filename}"

    vector_path     = "#{VECTORS_PATH}/#{target.original_filename}.npy"
    tmp_vector_path = "/tmp/#{target.original_filename}.npy"

    logger.debug "*** 3 : #{vector_path}"

    FileUtils.mv(image_path, tmp_img_path) # アップロードされたファイルをtmpへ移動

    ### プロセス ###
    Product.process_vector_core(tmp_img_path)

    FileUtils.mv(vector_path, tmp_vector_path) # 生成されたベクトルファイルをtmpへ移動

    Npy.load_string(File.read(tmp_vector_path)) # 抽出されたベクトルを返す
  rescue
    Product::ZERO_NARRAY
  end

  ### 抽出処理コア ###
  def self.process_vector_core(image_path)
    # プロセス
    logger.debug "*** process ***"

    cmd = "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{image_path}\";"
    logger.debug "*** 4 : #{cmd}"
    o, e, s = Open3.capture3(cmd)
  rescue => e
    logger.debug "*** X : rescue"
    logger.debug e
    return
  end

  ### S3リソース情報 ###
  def self.s3_resource
    Aws::S3::Resource.new(
      access_key_id:     Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region:            'ap-northeast-1', # Tokyo
    )
  end

  ### S3バケット ###
  def self.s3_bucket
    s3_resource.bucket(Rails.application.secrets.aws_s3_bucket)
  end

end
