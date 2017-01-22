class Bid::ApplicationController < ApplicationController
  before_action :check_rule
  before_action :authenticate_company!

  # layout 'layouts/application'

  def check_rule
    redirect_to "/bid/rule" if session[:bid_rule].blank? || session[:bid_rule] < (Time.now - 12.hours)
  end
end
