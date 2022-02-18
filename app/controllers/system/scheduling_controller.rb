class System::SchedulingController < ApplicationController
  require 'resolv'

  protect_from_forgery only: [:index]

  def index
  end

  # 定期実行処理
  def vectors_process
    @open_now.process_and_cache_all

    render plain: 'OK', status: 200
  end

  def recommend_products_mail
    @open     = @open_now
    @users    = User.where(id: DetailLog.all.select(:user_id)).order(:id)

    @temp_array = []
    @users.each do |us|
      tmp = DetailLog.joins(:product).where(user_id: us.id).group("products.genre_id").order("c" => :desc).limit(1).select("products.genre_id, count(*) as c").first.genre_id

      @genre    = Genre.find_by(id: tmp)
      @products = @open_now.products.listed
        .includes(:product_images)
        .where(genre_id: tmp)
        .order(:list_no)
        .limit(9)
      @rtag     = "mail_maitest_m-1_u-#{us.id}"

      next unless @products.count > 0

      # @temp_array << {
      #   user:     us,
      #   genre:    @genre,
      #   products: @products
      # }

      RecommendMailer.products(us.email, @open_now, @genre, @products, @rtag).deliver
      sleep 1
    end

    # mail      = "bata44883@gmail.com"
    # RecommendMailer.products(mail, @open_now, @genre, @products).deliver

    # render "recommend_mailer/products", layout: false
    render plain: 'OK', status: 200
  end

  def tracking
    status = SearchLog.create(
      keywords:    "",
      user_id:     user_signed_in? ? current_user.id : nil,

      path:        "MAI_test_mail",
      page:        1,

      host:       (Resolv.getname(ip) rescue ""),
      ip:          ip,
      r:           params[:r],
      referer:     "",
      ua:          request.user_agent,

      utag:       session[:utag],
    )

    # send_file Rails.root.join('app', 'assets', 'images', "1x1.png"), :type => 'image/gif', :disposition => 'inline'
    send_file Rails.root.join('app', 'assets', 'images', "mail_logo.png"), :type => 'image/gif', :disposition => 'inline'
  end
end