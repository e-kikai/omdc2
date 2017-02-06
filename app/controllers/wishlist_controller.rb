class WishlistController < ApplicationController
  before_action :check_open
  before_action :check_display

  before_action :init_wishlist

  include Exports

  def index
    @search    = @open_now.products.where(id: session[:wishlist]).search(params[:q])
    @products  = @search.result
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.pdf { export_pdf "#{@open_now.name}_入札依頼書.pdf" }
    end
  end

  def create
    session[:wishlist] << params[:id].to_i
    respond_to do |format|
      format.js
    end
  end

  def destroy
    session[:wishlist].delete(params[:id].to_i)
    respond_to do |format|
      format.js
    end
  end

  private

  def init_wishlist
    (session[:wishlist] ||= []).uniq!
  end
end
