class System::SchedulingController < ApplicationController
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
      tmp = DetailLog.joins(:product).where(user_id: us.id).group("products.genre_id").order("count(*) DESC").limit(1).select("products.genre_id")

      @genre    = Genre.find_by(id: tmp)
      @products = @open_now.products
        .includes(:product_images)
        .where(genre_id: tmp, product_images: ProductImage.select(:product_id))
        .order(:list_no).limit(9)

      next unless @products.count > 0

      @temp_array << {
        user:     us,
        genre:    @genre,
        products: @products
      }


    # RecommendMailer.products(us.email, @open_now, @genre, @products).deliver
  end

    # mail      = "bata44883@gmail.com"
    # @genre    = Genre.find(236)
    # @products = @open.products.includes(:product_images)
    #   .where(genre_id: 236, product_images: ProductImage.all).order(:list_no).limit(9)

    # @users = User.where(user_id: DetaiilLog.where(product_id: @open.products))

    # RecommendMailer.products(mail, @open_now, @genre, @products).deliver

    render "recommend_mailer/products", layout: false
  end
end
