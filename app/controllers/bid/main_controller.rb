class Bid::MainController < Bid::ApplicationController
  skip_before_action :check_rule, only: [:rule, :rule_update]
  skip_before_action :authenticate_company!, only: [:rule, :rule_update]
  def index
  end

  def edit_password
  end

  def rule
  end

  def rule_update
    session[:bid_rule] = Time.now
    redirect_to "/bid/login"
  end
end
