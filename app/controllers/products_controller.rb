class ProductsController < ApplicationController
  def index
    @products = @open_now.products.order(params[:order] || :list_no)
    @pproducts = @products.page(params[:page])
  end

  def show
  end
end
