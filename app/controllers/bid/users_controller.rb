class Bid::UsersController < Bid::ApplicationController
  before_action :get_user,  only: [:edit, :update, :destroy]

  def index
    @users = current_company.users

    @search  = current_company.users.search(params[:q])
    @users   = @search.result.order(created_at: :desc)
    @pusers  = @users.page(params[:page])
  end

  def new
    @user = current_company.users.new
  end

  def create
    @user = User.find_or_initialize_by(email: user_params[:email])

    user_name = "#{@user.company} #{@user.name}(#{@user.email})"

    # すでに取引ユーザ登録されている場合
    if @user.window_id.present?
      message = if current_company.id
        "#{user_name}は、すでに取引ユーザとして登録されています。"
      else
        "#{user_name}はすでに、他の組合位が取引ユーザとして登録されています。"
      end

      redirect_to "/bid/users/", alert: message and return
    else
      # 取引ユーザ(窓口商社)登録

      message = if @user.new_record?
        @user.attributes = user_params
        @user.skip_confirmation!

        "#{user_name}を取引ユーザとして新規登録しました。"
      else
        @user.attributes = user_params.slice(:tel, :zip, :addr)
        "#{user_name}は、すでにユーザ自身が一般ユーザ登録を行っております。\n\nメールアドレス、パスワード、会社名、氏名は上書きせずに、取引ユーザ登録のみ行いました。"
      end

      @user[:window_id] = current_company.id

      if @user.save
        # sendmail if @user.new_record? # 通知メール送信処理

        redirect_to "/bid/users/", notice: message
      else
        render :new
      end
    end

  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to "/bid/users/", notice: "#{@user.company} #{@user.name}(#{@user.email})のユーザ情報を変更しました。"
    else
      render :edit
    end
  end

  def destroy
    @user.update(window_id: nil)

    message = "#{@user.company} #{@user.name}(#{@user.email})の取引ユーザを解除しました。\n(一般ユーザとしてログインは行なえます)"
    redirect_to "/bid/users/", notice: message
  end

  def csv
  end

  # def csv_upload
  #   redirect_to "/bid/users/csv", alert: 'CSVファイルを選択してください' if params[:file].blank?
  #
  #   @res = @users.import_conf(params[:file])
  #
  #   redirect_to "/bid/users/csv", alert: 'ユーザ情報がありませんでした' if @res.length == 0
  # end
  #
  # def csv_import
  #   num = csv_products_params.length
  #
  #   redirect_to "/bid/users/csv", alert: '一括登録する商品がありません' if num == 0
  #
  #   @users.import(csv_products_params)
  #
  #   redirect_to("/bid/users/", notice: "#{num.to_s}件の商品を一括登録しました")
  # end

  private

  def get_user
      @user = current_company.users.find(params[:id])
    end

  def user_params
    params.require(:user).permit(:company, :name, :email, :password, :tel, :zip, :addr, :allow_mail)
  end

end
