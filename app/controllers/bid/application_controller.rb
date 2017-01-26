class Bid::ApplicationController < ApplicationController
  before_action :check_rule
  before_action :authenticate_company!

  # layout 'layouts/application'

  def check_rule
    redirect_to "/bid/rule" if session[:bid_rule].blank? || session[:bid_rule] < (Time.now - 12.hours)
  end

  private

  def check_open
    redirect_to "/bid/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry
    redirect_to "/bid/", notice: "現在、入札期間ではありません" unless @open_now
  end

  def check_bid
  end

  def check_result_list
  end

  def check_result_sum
  end

  def check_status(status)

  end

end
