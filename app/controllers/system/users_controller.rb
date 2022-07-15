class System::UsersController < System::ApplicationController
  include Exports

  def index
    @users  = User.all.order(id: :desc)

    @pusers = @users.page(params[:page])

    respond_to do |format|
      format.html
      format.csv {
        @users  = @users.where(allow_mail: true)

        favorites_now_sum = Favorite
          .joins(product: {genre: :large_genre })
          .group(:user_id, :xl_genre_id)
          .where("favorites.created_at > now() + '-6 month'")
          .pluck("user_id, xl_genre_id, row_number() over(partition by user_id order by count(*) DESC)")
          .select { |a| a[2] == 1 }.map { |a| [a[0], a[1]] }.to_h

        favorites_sum = Favorite
          .joins(product: {genre: :large_genre })
          .group(:user_id, :xl_genre_id)
          .pluck("user_id, xl_genre_id, row_number() over(partition by user_id order by count(*) DESC)")
          .select { |a| a[2] == 1 }.map { |a| [a[0], a[1]] }.to_h

        detail_logs_now_sum = DetailLog
          .joins(product: {genre: :large_genre })
          .group(:user_id, :xl_genre_id)
          .where("detail_logs.created_at > now() + '-6 month'")
          .pluck("user_id, xl_genre_id, row_number() over(partition by user_id order by count(*) DESC)")
          .select { |a| a[2] == 1 && a[0].present? }.map { |a| [a[0], a[1]] }.to_h

        detail_logs_sum = DetailLog
          .joins(product: {genre: :large_genre })
          .group(:user_id, :xl_genre_id)
          .pluck("user_id, xl_genre_id, row_number() over(partition by user_id order by count(*) DESC)")
          .select { |a| a[2] == 1 && a[0].present? }.map { |a| [a[0], a[1]] }.to_h

        @fav_xls = detail_logs_sum.merge(favorites_sum, detail_logs_now_sum, favorites_now_sum)

        export_csv "users_#{@open_id}.csv"
      }
    end
  end

  def destroy
    @user = current_company.users.find(params[:id])

    @user.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@user.company} #{@user.name}(#{@user.email})を削除しました"
  end

end
