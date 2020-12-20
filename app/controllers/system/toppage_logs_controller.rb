class System::ToppageLogsController < System::ApplicationController
  def index
    @toppage_logs  = ToppageLog.all.includes(:user).order(id: :desc)

    @ptoppage_logs = @toppage_logs.page(params[:page])
  end
end
