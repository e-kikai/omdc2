class ProductsController < ApplicationController
  before_action :check_open
  before_action :get_product, only: [:show, :contact, :contact_tel, :contact_do]

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

    @search = @open_now.products.with_keywords(params[:keywords]).search(queries)

    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])
  end

  def qr
    if    system_signed_in? && @open_now.status == :list
      redirect_to "/system/list/#{params[:id]}/edit"
    elsif system_signed_in? && @open_now.status == :carry_out
      redirect_to "/system/carry_out/#{params[:id]}/edit"
    else
      redirect_to "/detail/#{params[:id]}/"
    end
  end

  def show
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

  private

  def check_open
    redirect_to "/", alert: "現在、開催されている入札会はありません" unless @open_now
  end

  def get_product
    @product = @products.find(params[:id])
  end
end
