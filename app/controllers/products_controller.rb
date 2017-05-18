class ProductsController < ApplicationController
  before_action :check_open
  before_action :check_display
  before_action :get_product, only: [:show, :contact, :contact_tel, :contact_do]

  include Exports

  def index
    queries = if params[:xl_genre_id].present?
      @xl_genre = XlGenre.find(params[:xl_genre_id])
      {xl_genre_id_eq: params[:xl_genre_id]}.merge(Hash(params[:q]))
    elsif params[:large_genre_id].present?
      @large_genre = LargeGenre.find(params[:large_genre_id])
      {large_genre_id_eq: params[:large_genre_id]}.merge(Hash(params[:q]))
    elsif params[:genre_id].present?
      @genre = Genre.find(params[:genre_id])
      {genre_id_eq: params[:genre_id]}.merge(Hash(params[:q]))
    else
      params[:q]
    end

    @search = @products.with_keywords(params[:keywords]).search(queries)

    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open_now.name}_検索結果.csv" }
    end
  end

  def qr
    product_id = if params[:key] =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)$/
      product = Product.find_by(open_id: $1, company_no: $2, app_no: $3)
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
      redirect_to "/detail/#{product_id}/"
    end
  end

  def show
  end

  def images
      @product = @open_now.products.includes(:company, :genre, :large_genre, :xl_genre, :area, :product_images).find(params[:id])
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
      redirect_to "/detail/#{@product.id}"
    else
      redirect_to "/", alert: "リストNo.「#{params[:list_no]}」の商品はありませんでした"
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

  private

  def get_product
    @product = @products.find(params[:id])
  end
end
