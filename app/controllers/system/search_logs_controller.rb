class System::SearchLogsController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @search_logs  = SearchLog.all.includes(:user).where(@where).order(id: :desc)

    @psearch_logs = @search_logs.page(params[:page])
    respond_to do |format|
      format.html
      format.csv { export_csv "search_logs.csv" }
    end
  end
end
