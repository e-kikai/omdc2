class ProductsController < ApplicationController
  require 'resolv'

  ROBOTS = /(google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws)/

  before_action :check_open,      except: [:images, :youtube, :ml_get_genre]
  before_action :check_display,   except: [:images, :youtube, :ml_get_genre]
  before_action :get_product,     only: [:show, :contact, :contact_tel, :contact_do]
  before_action :get_product_all, only: [:images, :youtube,]

  before_action :fluent_before, only: [:show]
  after_action  :fluent_log,    only: [:show]

  include Exports

  def index
    queries = params[:q].present? ? params[:q].permit!.to_h : {}
    if params[:xl_genre_id].present?
      @xl_genre = XlGenre.find(params[:xl_genre_id])
      queries[:xl_genre_id_eq] = params[:xl_genre_id]
    elsif params[:large_genre_id].present?
      @large_genre = LargeGenre.find(params[:large_genre_id])
      queries[:large_genre_id_eq] = params[:large_genre_id]
    elsif params[:genre_id].present?
      @genre    = Genre.find(params[:genre_id])
      @products = @products.where(genre_id: params[:genre_id])
    elsif Product.special_title(params[:special_key]).present?
      @special_title = Product.special_title(params[:special_key])
      @products      = @products.special(params[:special_key])
    end

    @search = @products.with_keywords(params[:keywords]).search(queries)

    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open_now.name}_products.csv" }
    end
  end

  def list_no
    page       = (params[:page] || 1).to_i
    where_rage = (page * 100 - 99)..(page * 100)
    @max = @products.maximum(:list_no)

    @pproducts = @products.where(list_no: where_rage).order(:list_no)
  end

  def bid_list
    @search = @products.search(params[:q])

    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    @max_list_no = @open_now.products.listed.maximum(:list_no)

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open_now.name}_bid_list.csv" }
    end
  end

  def qr
    product_id = if params[:key] =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)$/
      product = Product.includes(:company).find_by(open_id: $1, companies: {no: $2}, app_no: $3)
      raise "#{params[:key]} 商品情報がありません" if product.blank?

      product.id
    else
      params[:id]
    end

    if system_signed_in?
      if @open_now.bid_end?
        redirect_to "/system/list/carryout/#{product_id}"
      else
        redirect_to "/system/list/#{product_id}/edit"
      end
    else
      # redirect_to "/detail/#{product_id}/?ref=#{params[:place]}"
      redirect_to "/products/#{product_id}/?r=qr_#{params[:place]}"
    end
  end

  def show
    # @samegenres = @products.where(genre: @product.genre).limit(5)
    # @likeimgs   = @products.image_vector_sort(@product.id, 5)

    @samegenres = @products.where(genre: @product.genre).limit(16)
    # @likeimgs   = @products.image_vector_sort(@product.id, 16)
    @likeimgs = Rails.cache.fetch("likeimgs_#{@product.id}_16", expires_in: 1.day) do
      @products.image_vector_sort(@product.id, 16)
    end
  end

  def images
  end

  def youtube
  end

  # def contact
  # end
  #
  # def contact_tel
  # end
  #
  # def contact_do
  # end

  def search_by_list_no
    if @product = @products.find_by(list_no: params[:list_no])
      redirect_to "/products/#{@product.id}"
    else
      redirect_to "/search", alert: "リストNo.「#{params[:list_no]}」の商品はありませんでした"
    end
  end

  # def search_by_ml
  #   genre_id = Product.ml_get_genre({name: params[:name]}).to_i
  #   if genre_id > 0
  #     redirect_to "/genre/#{genre_id}"
  #   else
  #     redirect_to "/", alert: "商品名「#{params[:name]}」の商品はありませんでした"
  #   end
  # end

  def ml_get_genre
    @genre_id = Product.search_genre(params[:product])

    respond_to do |format|
      format.html { render plain: @genre_id.to_s}
      format.js { }
    end
  end

  def image_vector_search
    ### 商品が選択されている場合 ###
    if params[:id].present?
      get_product

      @products = @products.image_vector_sort(@product.id, Product::VECTORS_LIMIT)
    end
  end

  def image_vector_search_by_file
    if params[:image]
      @products = @products.image_vector_sort_by_file(params[:image], Product::VECTORS_LIMIT)
    end
  end

  ### 検索結果用の画像表示用 ###
  def image
    tmp_img_path = "/tmp/#{params[:filename]}"

    respond_to do |format|
      format.jpeg { send_file tmp_img_path, type: 'image/jpeg', disposition: 'inline' }
    end
  end

  private

  def get_product
    @product = @products.find(params[:id])
  end

  def get_product_all
    @product = Product.includes(:company, :genre, :large_genre, :xl_genre, :area, :product_images).find(params[:id])
  end

  def fluent_before
    @start_time = Time.now
  end

  def fluent_log
    if @product.present?
      # ip     = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
      ip     = request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
      host   = (Resolv.getname(ip) rescue "")

      if host.present? && host !~ ROBOTS
        Fluent::Logger::FluentLogger.open(nil, host: 'localhost', port: 24224)
        channel = {
          start_time:     @start_time,
          response:       Time.now - @start_time,
          # method:       request.request_method,
          # request_path: request.fullpath,
          # ip:             request.remote_ip,
          ip:             ip,
          host:           host,

          referer:        request.referer,
          UA:             request.user_agent,

          ref:            params[:ref],

          genre_id:       @product.genre_id,
          genre:          @product.genre.name,
          large_genre_id: @product.large_genre.id,
          large_genre:    @product.large_genre.name,
          xl_genre_id:    @product.xl_genre.id,
          xl_genre:       @product.xl_genre.name,

          company_id:     @product.company_id,
          company:        @product.company.try(:name),

          area_id:        @product.area_id,
          area:           @product.area.try(:name),
        }.merge(@product.attributes.slice("id", "list_no", "name", "maker", "model", "year", "min_price"))

        Fluent::Logger.post("omdc2", channel)
      end
    end

    # throw channel
  end
end
