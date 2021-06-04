class System::FavoritesController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @favorites  = Favorite.unscoped.includes(:user,  product: [:company, genre: [large_genre: [:xl_genre]]]).where(@where).order(id: :desc)

    @pfavorites = @favorites.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "favorite_logs.csv" }
    end
  end
end
