class MainController < ApplicationController
  # skip_before_action :get_open_now, only: [:qrcode]

  def index
    if @open_now
      @all_xl_counts    = @products.joins(:xl_genre).group("xl_genres.id", "xl_genres.name", "xl_genres.order_no").order("xl_genres.order_no").count
      @all_large_counts = @products.joins(:large_genre)
        .group("large_genres.id", "large_genres.xl_genre_id", "large_genres.name", "large_genres.order_no")
        .order("large_genres.order_no").count

      @search = @open_now.products.search
    end
  end

  # def qrcode
  #   data = RQRCode::QRCode.new(params[:url], size: 4, level: :m).as_png(
  #     resize_gte_to: false,
  #     resize_exactly_to: false,
  #     fill: 'white',
  #     color: 'black',
  #     size: 70,
  #     border_modules: 0,
  #     module_px_size: 2,
  #     file: nil # path to write
  #   )
  #
  #   respond_to do |format|
  #     format.png { send_data data, type: "image/png", disposition: 'inline' }
  #   end
  # end
end
