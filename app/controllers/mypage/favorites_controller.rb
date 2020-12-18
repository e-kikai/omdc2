class Mypage::FavoritesController < Mypage::ApplicationController
  before_action :get_favorites

  def index
    @search    = @products.where(id: @favorites.select(:product_id)).search(params[:q])
    @products  = @search.result.includes(:product_images)

    # @pproducts = @products.page(params[:page])
  end

  # def create
  #   @watch = @favorites.new(product_id: params[:id])
  #   if @watch.save
  #     redirect_to "/mypage/favorites", notice: "お気に入りに登録しました"
  #   else
  #     redirect_to "/mypage/favorites", alert: "既にお気に入りに登録されています"
  #   end
  # end
  #
  # def destroy
  #   @watch = @favorites.find_by(product_id: params[:id])
  #   @watch.soft_destroy!
  #   redirect_to "/mypage/favorites/", notice: "お気に入りから商品を削除しました"
  # end

  ### お気に入り切替 ###
  def toggle
    @product_id = params[:id]
    @favorite   = @favorites.find_by(product_id: @product_id)

    if @favorite.blank?
      @favorite = @favorites.create(product_id: @product_id)
    else
      @favorite.soft_destroy!
    end
  end

  private

  def get_favorites
    @favorites = current_user.favorites
  end
end
