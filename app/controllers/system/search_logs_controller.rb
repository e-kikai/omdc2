class System::SearchLogsController < System::ApplicationController
  def index
    @search_logs  = SearchLog.all.includes(:user).order(id: :desc)

    @psearch_logs = @search_logs.page(params[:page])
  end
end
