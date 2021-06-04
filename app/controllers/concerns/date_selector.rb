module DateSelector
  extend ActiveSupport::Concern

  ### 管理者ページの期間選択共通部分 ###
  def date_selector
    @date_start = (params[:date_start] || Date.today - 1.week).to_date
    @date_end   = (params[:date_end] || Date.today).to_date
    @where      = {created_at: @date_start.beginning_of_day..@date_end.end_of_day}
  end
end
