class System::MainController < System::ApplicationController
  def index
  end

  def edit_password
    @system = current_system
  end

  def update_password
    @system = current_system
    if @system.update_with_password(password_params)
      redirect_to "/system/", notice: 'パスワードを変更しましたので、再度ログインしてください'
    else
      render :edit_password
    end
  end

  private

  def password_params
    params.require(:system).permit(:password, :password_confirmation, :current_password)
  end
end
