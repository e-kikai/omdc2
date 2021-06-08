class System::DetailLogsController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @detail_logs  = DetailLog.all.includes(:user, product: [:company, :area, :success_bid, :success_company, genre: [large_genre: [:xl_genre]]]).where(@where).order(id: :desc)

    @pdetail_logs = @detail_logs.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "detail_logs.csv" }
    end
  end
end
