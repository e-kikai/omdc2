class Bid::ApplicationController < ApplicationController
  layout 'layouts/application'

  before_action :check_rule
  before_action :authenticate_company!
  before_action :check_default_password

  def check_rule
    redirect_to "/bid/rule" if session[:bid_rule].blank? || session[:bid_rule] < (Time.now - 12.hours)
  end

  def check_default_password
    if current_company.valid_password? "ikomamember"
      redirect_to "/bid/edit_password", notice: "初期パスワード「ikomamember」は、必ず変更する必要があります。\nパスワード変更をよろしくお願いします。"
    end
  end

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
