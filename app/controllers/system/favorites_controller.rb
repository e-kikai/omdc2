class System::FavoritesController < System::ApplicationController
  def index
    @favorites  = Favorite.unscoped.includes(:user, :product).order(id: :desc)

    @pfavorites = @favorites.page(params[:page])
  end

end
