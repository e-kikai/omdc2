class WishlistController < ApplicationController
  before_action :check_open

  def index
    @search    = @open_now.products.where(id: session[:wishlist]).search(params[:q])
    @products  = @search.result
    @pproducts = @products.page(params[:page])
  end

  def create
    Array(session[:wishlist]) << params[:id]
  end

  def destroy
    Array(session[:wishlist]).delete!(params[:id])
  end

  def pdf
    @open_now.products.where(id: session[:wishlist]).search(params[:q])
    @products  = @search.result
  end

  private

  def check_open
    redirect_to "/", alert: "現在、開催されている入札会はありません" unless @open_now
  end
end
