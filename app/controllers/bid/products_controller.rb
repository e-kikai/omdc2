class Bid::ProductsController < Bid::ApplicationController
  before_action :check_open
  before_action :check_entry_date, extract: [:index]
  before_action :products
  before_action :get_product, only: [:edit, :update, :destroy, :image_upload, :image_destroy, :images_order]

  def index
  end

  def new
    @product = @products.new
  end

  def create
    @product = @products.new(product_params)
    if @product.save
      redirect_to "/bid/products/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to "/bid/products/", notice: "#{@product.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@product.name}を削除しました"
  end

  def ml_get_genre
    # @genre_id = Product.ml_get_genre(params[:product])
    @genre_id = Product.search_genre(params[:product])

    respond_to do |format|
      format.html { render plain: @genre_id.to_s}
      format.js { }
    end
  end

  def images
    @products = @products.includes(:product_images)
  end

  def image_upload
    product_image = @product.product_images.build
    begin
      ProductImage.transaction do
        product_image.save!
        product_image.update!(image: params[:image])
      end
      render status: 200, json: product_image
    rescue ActiveRecord::RecordInvalid
      render status: 500, json: product_image.errors.full_messages.to_s
    end
  end

  def images_order
    params[:images].each.with_index do |i, key|
      @product.product_images.find(i).update(order_no: (key + 1) * 10)
    end
  end

  def image_destroy
    @product.product_images.find(params[:product_image_id]).destroy
    respond_to do |format|
      format.html
      format.json { render :json =>  true }
    end
  end

  private

  def check_open
    redirect_to "/bid/", alert: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/bid/", alert: "現在、出品期間ではありません" unless @open_now
  end

  def products
    @search   = @open_now.products.search(params[:q])
    @products = @search.result.where(company_id: current_company.id)
  end

  def get_product
    @product = @products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama)
  end
end
