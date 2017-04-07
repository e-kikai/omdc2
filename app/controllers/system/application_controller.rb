class System::ApplicationController < ApplicationController
  before_action :authenticate_system!

  # layout 'layouts/application'

  private

  def get_companies_selector
    @companies_selector = Company.order(:no).pluck("no || ' : ' || name", :id)
    session[:system_company_id] = params[:company_id] if params[:company_id].present?

    @company = Company.find_by(id: session[:system_company_id]) if session[:system_company_id].present?
  end

  def check_open
    redirect_to "/system/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_start
    redirect_to "/system/", notice: "現在、出品期間ではありません" unless @open_now.entry_start?
  end

  def check_bid_start
    redirect_to "/system/", notice: "現在、入札期間ではありません" unless @open_now.bid_start?
  end

  def check_result_list
    redirect_to "/system/", notice: "落札結果表示まで、しばらくお待ち下さい" unless @open_now.result_list?
  end

  def check_result_sum
    redirect_to "/system/", notice: "計算表表示まで、しばらくお待ち下さい" unless @open_now.result_sum?
  end
end
