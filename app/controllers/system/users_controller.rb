class System::UsersController < System::ApplicationController
  def index
    @users  = User.all.order(id: :desc)

    @pusers = @users.page(params[:page])
  end

  def destroy
    @user = current_company.users.find(params[:id])

    @user.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@user.company} #{@user.name}(#{@user.email})を削除しました"
  end

end
