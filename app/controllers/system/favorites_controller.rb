class System::FavoritesController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @favorites  = Favorite.unscoped.includes(:user, :product).where(@where).order(id: :desc)

    @pfavorites = @favorites.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "favorite_logs.csv" }
    end
  end
end
