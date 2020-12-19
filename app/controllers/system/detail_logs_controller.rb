class System::DetailLogsController < System::ApplicationController
  def index
    @detail_logs  = DetailLog.all.includes(:user, :product).order(id: :desc)

    @pdetail_logs = @detail_logs.page(params[:page])
  end
end
