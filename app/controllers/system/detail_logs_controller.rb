class System::DetailLogsController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @detail_logs  = DetailLog.all.includes(:user, product: [:company, genre: [large_genre: [:xl_genre]]]).where(@where).order(id: :desc)

    @pdetail_logs = @detail_logs.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "detail_logs.csv" }
    end
  end
end
