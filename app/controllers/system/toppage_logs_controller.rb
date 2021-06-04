class System::ToppageLogsController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @toppage_logs  = ToppageLog.all.includes(:user).where(@where).order(id: :desc)

    @ptoppage_logs = @toppage_logs.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "toppage_logs.csv" }
    end
  end
end
