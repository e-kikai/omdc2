class System::PlaygroundController < ApplicationController
  require "open3"
  include Exports

  before_action :change_db
  after_action  :restore_db
  rescue_from   { restore_db }

  layout "application_02"


  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"

  S3_VECTORS_PATH = "vectors"
  ZERO_NARRAY  =  Numo::SFloat.zeros(1)
  VECTOR_CACHE = "vector"


  def search_01
    # 初期検索クエリ作成
    @open = Open.find(@open_id)
    @products = @open.products.includes(:product_images, :genre, :company).order(:id)

    ### 通常サーチ ###
    ### 検索キーワード ###
    @keywords = params[:keywords].to_s

    # 初期検索クエリ作成
    @products = @products.with_keywords(@keywords)

    # genre
    if params[:genre_id].present?
      @genre = Genre.find(params[:genre_id])
      @products = @products.search(genre_id_eq: @genre.id).result
    end



    if params[:product_id]
      ### 似たものサーチ ###
      @time = Benchmark.realtime do
        @target = Product.find(params[:product_id])

        @products = @open.products.includes(:product_images, :genre, :company).order(:id) if params[:scope] == "all" # 全体検索
        @sorts = sort_by_vector(@target, @products)

        @products = @products.where(id: @sorts.keys).sort_by { |pr| @sorts[pr.id] }

        # @products = sort_by_vector(@target, @products)
      end
    else
      ### ページャ ###
      @pproducts = @products.page(params[:page])
    end

    ### 検索セレクタ ###
    @genre_selector = Genre.options

    respond_to do |format|
      format.html
      format.csv { export_csv "products_images.csv" }
    end
  end

  def search_02
    # 初期検索クエリ作成
    @open = Open.find(@open_id)

    ### 画像ファイル検索 ###
    if params[:image]
      @time = Benchmark.realtime do
        @products = @open.products.includes(:product_images, :genre, :company)
        @sorts = sort_by_vector(params[:image], @products)

        @products = @products.where(id: @sorts.keys).sort_by { |pr| @sorts[pr.id] }
      end
    end
  end

  def image
    tmp_img_path = "#{VECTORS_PATH}/#{params[:filename]}"

    respond_to do |format|
      format.jpeg { send_file tmp_img_path, type: 'image/jpeg', disposition: 'inline' }
    end
  end

  def mock_list_01
  end

  def mock_list_02
    @open     = Open.find(@open_id)
    @products = @open.products.includes(:company).order("random()").limit(25)

  end

  ### ベクトル一括変換 ###
  def vector_maker
    ### データを取得 ###
    @open     = Open.find(@open_id)
    @product_ids = @open.products.order(id: :asc).pluck(:id)

    @product_ids.each do |product_id|
      logger.debug "[[ #{product_id} ]]"
      process_vector(product_id)
    end

    redirect_to "/system/playground/search_01", notice: "変換完了"
  end

  ### ベクトル変換処理 ###
  def vector_maker_solo
    @time = Benchmark.realtime do
      ### 初期化 ###
      resource = Aws::S3::Resource.new(
        access_key_id:     Rails.application.secrets.aws_access_key_id,
        secret_access_key: Rails.application.secrets.aws_secret_access_key,
        region:            'ap-northeast-1', # Tokyo
      )

      bucket = resource.bucket(@bucket_name)

      logger.debug "*** 1 : #{@bucket_name}"

      ### ターゲット商品情報取得 ###
      product = Product.find(params[:id])

      vector_key  = "vectors/vector_#{product.id}.npy"

      if product.product_images.first.blank?
        ### 画像の有無チェック ###
        redirect_to "/system/playground/search_01", alert: "商品に画像が登録されていません" and return
      elsif bucket.object(vector_key).exists?
        ### ベクトルファイルの存否を確認 ###
        redirect_to "/system/playground/search_01", alert: "ベクトルファイルがすでに存在します" and return
      end
      logger.debug "*** 2 : #{vector_key}"

      ### S3より画像ファイルの取得 ###
      @filename   = product.product_images.first.image_identifier
      image_id    = product.product_images.first.id
      image_key   = "uploads/product_image/image/#{image_id}/#{@filename}"

      image_path  = "#{UTILS_PATH}/static/img/#{@filename}"
      vector_path = "#{VECTORS_PATH}/#{@filename}.npy"

      logger.debug "*** 3 : #{image_key}"

      bucket.object(image_key).get(response_target: "#{image_path}")

      logger.debug "*** 4 : #{image_path}"

      ### プロセス ###
      cmds = []
      cmds << "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{image_path}\";"
      exec_commands(cmds)

      logger.debug "*** 5 : #{vector_path}"

      ### ベクトルファイルアップロード ###
      bucket.object(vector_key).upload_file(vector_path)

      logger.debug "*** 6 : upload"


      ### 不要になった画像ファイル、ベクトルファイルの削除
      File.delete(vector_path)
      File.delete(image_path)

      logger.debug "*** 7 : delete"
    end

    ### ベクトルキャッシュ更新 ###
    # update_vector

    redirect_to "/system/playground/search_01", notice: "ベクトル変換完了 : #{@filename} : #{@time}"
  # rescue => e
  #   redirect_to "/system/playground/search_01", alert: "ベクトル変換エラー : #{e.message}"
  end

  def show
    @open = Open.find(@open_id)
    @products = @open.products.includes(:product_images, :genre, :company).order(:id)

    @product = @products.find(params[:id])

    ### ジャンルレコメンド ###
    @genre_recommend = @products.includes(:product_images, :genre, :company).where(genre: @product.genre).limit(32)

    ### 似たものレコメンド ###
    @sorts              = sort_by_vector(@product, @products, 12)
    @nitamono_recommend = @products.where(id: @sorts.keys).sort_by { |pr| @sorts[pr.id] }
  end

  private

  ### ベクトル変換処理 ###
  def process_vector(product_id)
    ### 初期化 ###
    resource = Aws::S3::Resource.new(
      access_key_id:     Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region:            'ap-northeast-1', # Tokyo
    )

    bucket = resource.bucket(@bucket_name)

    logger.debug "*** 1 : #{@bucket_name}"

    ### ターゲット商品情報取得 ###
    product = Product.find(product_id)

    vector_key  = "vectors/vector_#{product.id}.npy"

    image = product.product_images.first

    logger.debug bucket.object(vector_key).exists?
    if image.blank?  # 画像の有無チェック
      logger.debug "*** E : 商品に画像が登録されていません"
      return false

      # errors.add(:base, '商品に画像が登録されていません') and return false
    elsif bucket.object(vector_key).exists? # ベクトルファイルの存否を確認
      logger.debug "*** E : ベクトルファイルがすでに存在します"
      return false

      # errors.add(:base, 'ベクトルファイルがすでに存在します') and return false
    end

    logger.debug "*** 2 : #{vector_key}"

    filename    = image.image_identifier
    image_id    = image.id
    image_key   = "uploads/product_image/image/#{image_id}/#{filename}"

    image_path  = "#{UTILS_PATH}/static/img/#{filename}"
    vector_path = "#{VECTORS_PATH}/#{filename}.npy"

    logger.debug "*** 3 : #{image_key}"

    bucket.object(image_key).download_file(image_path) # S3より画像ファイルの取得

    # プロセス
    cmd = "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{image_path}\";"
    logger.debug "*** 4 : #{cmd}"
    o, e, s = Open3.capture3(cmd)
    # logger.debug o
    # logger.debug e
    # logger.debug s

    logger.debug "*** 5 : #{vector_path}"

    bucket.object(vector_key).upload_file(vector_path) # ベクトルファイルアップロード

    logger.debug "*** 6 : upload"

    ### 不要になった画像ファイル、ベクトルファイルの削除
    File.delete(vector_path, image_path)

    logger.debug "*** 7 : delete"

    self
  rescue
    logger.debug "*** X : rescue"
    return
  end

  ### キャッシュ更新 ###
  def update_vector(rehash=false)
    pids = Product.status(Product::STATUS[:mix]).order(:id).pluck(:id).uniq

    vectors = if rehash
      {}
    else
      Rails.cache.read("vectors") || {}
    end

    update_flag = false
    pids.each do |pid|
      ### ベクトルの確認 ###
      if vectors[pid].blank? && File.exist?("#{VECTORS_PATH}/vector_#{pid}.npy")
        update_flag  = true # 更新あり
        vectors[pid] = Npy.load("#{VECTORS_PATH}/vector_#{pid}.npy")
      end
    end

    ### ベクトルキャシュ更新 ###
    Rails.cache.write("vectors", vectors) if update_flag == true
  end

  def exec_commands(commands)
    commands.each do |cmd|
      logger.debug cmd
      o, e, s = Open3.capture3(cmd)
      logger.debug o
      logger.debug e
      logger.debug s

    end
  end

  def sort_by_vector(target, products, limit=50)
    logger.debug ":::: start ::::::"

    return Product.none if target.nil?

    vectors = Rails.cache.read(VECTOR_CACHE) || {} # キャッシュからベクトル群を取得

    ### 初期化 ###
    resource = Aws::S3::Resource.new(
      access_key_id:     Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region:            'ap-northeast-1', # Tokyo
    )

    bucket = resource.bucket(@bucket_name)
    update_flag = false

    ### ターゲットベクトル取得 ###
    target_vector =  if target.try(:path)  # 画像ファイルから
      image_path      = target.path
      tmp_img_path    = "#{VECTORS_PATH}/#{target.original_filename}"

      vector_path     = "#{VECTORS_PATH}/#{target.original_filename}.npy"
      tmp_vector_path = "/tmp/#{target.original_filename}.npy"

      logger.debug "*** 3 : #{vector_path}"

      ### 同じファイルがなければ ###
      unless File.exist? tmp_vector_path
        FileUtils.mv(image_path, tmp_img_path)

        # プロセス
        logger.debug "*** process ***"

        cmd = "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{tmp_img_path}\";"
        logger.debug "*** 4 : #{cmd}"
        o, e, s = Open3.capture3(cmd)

        FileUtils.mv(vector_path, tmp_vector_path)
      end

      Npy.load_string(File.read(tmp_vector_path))
    elsif vectors[target.id].present? # キャッシュからベクトル取得
      vectors[target.id]
    elsif bucket.object("#{S3_VECTORS_PATH}/vector_#{target.id}.npy").exists? # アップロードファイルからベクトル取得
      str = bucket.object("#{S3_VECTORS_PATH}/vector_#{target.id}.npy").get.body.read
      Npy.load_string(str)
    else # ない場合
      nil
    end

    return Product.none if target_vector.nil?

    sorts = products.distinct.pluck(:id).map do |pid|
      ### ベクトルの取得 ###
      pr_narray = if vectors[pid].present? && vectors[pid] != ZERO_NARRAY # 既存
        vectors[pid]
      else # 新規(ファイルからベクトル取得して追加)
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
        sub = pr_narray - target_vector
        res = (sub * sub).sum

        # logger.debug "#{pid} : #{res}"

        # (res > 0 || mine == true) ? [pid, res]  : nil
        (res > 0 ) ? [pid, res]  : nil
      end
    end.compact.sort_by { |v| v[1] }.first(limit).to_h


    # ベクトルキャシュ更新
    Rails.cache.write(VECTOR_CACHE, vectors) if update_flag == true

    # 結果を返す
    sorts
  end

  ### テスト用DB切替 ###
  def change_db
    # Thread.current[:request] = request

    case Rails.env
    when "production"; redirect_to "/"
    when "staging"
      ActiveRecord::Base.establish_connection(:test_01)
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/omdc2/uploads/product_image/image"
      # @link_base   = "https://www.大阪機械団地.jp/"
      @link_base   = "http://52.198.41.71/"
      @bucket_name = "omdc2"

      @open_id = 59
    when "development"
      ActiveRecord::Base.establish_connection(:test_01)
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/omdc2/uploads/product_image/image"
      # @link_base   = "https://www.大阪機械団地.jp/"
      @link_base   = "http://192.168.33.110:8082/"
      @bucket_name = "omdc2"

      @open_id = 59
    else
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/development.omdc2/uploads/product_image/image"
      @link_base   = "http://192.168.33.110:8082/"
      @bucket_name = Rails.application.secrets.aws_s3_bucket

      @open_id = 43
    end
  end

  ### DB切替を戻す ###
  def restore_db
    if Rails.env == "staging"
      ActiveRecord::Base.establish_connection(:staging)
    end
  end

  def search_02_params
    params.permit(:images)
  end
end
