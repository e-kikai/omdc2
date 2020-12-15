class Mypage::UserController < Mypage::ApplicationController
  before_action :get_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to "/mypage/", notice: "ユーザ情報を変更しました"
    else
      render :edit
    end
  end

  private

  def get_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :name, :company, :allow_mail)
  end
end
