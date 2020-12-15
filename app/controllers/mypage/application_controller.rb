class Mypage::ApplicationController < ApplicationController
  layout 'layouts/application_02'

  before_action :authenticate_user!


  private

  def check_open
    redirect_to "/bid/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry
    redirect_to "/bid/", notice: "現在、出品期間ではありません" unless @open_now.entry? && current_company.entry
  end

  def check_entry_start
    redirect_to "/bid/", notice: "現在、出品期間ではありません" unless @open_now.entry_start? && current_company.entry
  end

  def check_bid
    redirect_to "/bid/", notice: "現在、入札期間ではありません" unless @open_now.bid?
  end

  def check_result_list
    redirect_to "/bid/", notice: "落札結果表示まで、しばらくお待ち下さい" unless @open_now.result_list?
  end

  def check_result_sum
    redirect_to "/bid/", notice: "計算表表示まで、しばらくお待ち下さい" unless @open_now.result_sum?
  end

  def check_status(status)

  end

end
