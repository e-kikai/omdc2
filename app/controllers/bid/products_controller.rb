class Bid::ProductsController < ApplicationController
  before_action :check_open
  before_action :check_entry_date, extract: [:index]
  before_action :products

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
    @product = @products.find(params[:id])
  end

  def update
    @product = @products.find(params[:id])
    if @product.update(product_params)
      redirect_to "/bid/products/", notice: "#{@company.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product = @products.find(params[:id])
    @product.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@product.name}を削除しました"
  end

  def ml_get_genre
    @genre_id = Product.ml_get_genre(params[:product])

    respond_to do |format|
      format.html { render plain: @genre_id.to_s}
      format.js { }
    end
  end

  private

  def check_open
    redirect_to "/bid/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/bid/", notice: "現在、出品期間ではありません" unless @open_now
  end

  def products
    @products = @open_now.products.where(company_id: current_company.id)
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :comment, :min_price, :genre_id)
  end
end
