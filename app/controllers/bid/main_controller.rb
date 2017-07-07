class Bid::MainController < Bid::ApplicationController
  skip_before_action :check_rule, only: [:rule, :rule_update]
  skip_before_action :authenticate_company!, only: [:rule, :rule_update]
  skip_before_action :check_default_password, only: [:rule, :rule_update, :edit_password, :update_password]

  def index
  end

  def edit_password
    @company = current_company
  end

  def update_password
    @company = current_company
    if @company.update_with_password(password_params)
      redirect_to "/bid/login", notice: 'パスワードを変更しましたので、再度ログインしてください'
    else
      render :edit_password
    end
  end

  def rule
  end

  def rule_update
    session[:bid_rule] = Time.now
    redirect_to "/bid/login"
  end

  private

  def password_params
    params.require(:company).permit(:password, :password_confirmation, :current_password)
  end
end
