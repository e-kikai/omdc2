class Mypage::MainController < Mypage::ApplicationController
  before_action :get_user

  def index
  end

  def edit_password
  end

  def update_password
    if @user.update_with_password(password_params)
      redirect_to "/mypage/", notice: 'パスワードを変更しましたので、再度ログインしてください。'
    else
      render :edit_password
    end
  end

  def edit_user
  end

  def update_user
    if @user.update(user_params)
      redirect_to "/mypage/", notice: 'ユーザ情報を変更しました。'
    else
      render :edit_user
    end
  end

  private

  def get_user
    @user = current_user
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def user_params
    params.require(:user).permit(:company, :name, :email, :allow_mail)
  end
end
