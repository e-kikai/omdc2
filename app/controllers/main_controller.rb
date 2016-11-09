class MainController < ApplicationController
  def index
    if @open_now
      # @xl_genres =  XlGenre.all

      # raise @genres = Genre.where(products: @products).to_sql

      @all_xl_counts    = @products.joins(:xl_genre).group("xl_genres.id", "xl_genres.name", "xl_genres.order_no").order("xl_genres.order_no").count
      @all_large_counts = @products.joins(:large_genre)
        .group("large_genres.id", "large_genres.xl_genre_id", "large_genres.name", "large_genres.order_no")
        .order("large_genres.order_no").count

      # @xl_counts    = @products.joins(:xl_genre).group("xl_genres.id", "xl_genres.name", "area", "xl_genres.order_no").order("xl_genres.order_no").count
      # @large_counts = @products.joins(:large_genre)
      #   .group("large_genres.id", "large_genres.xl_genre_id", "large_genres.name", "area", "large_genres.order_no")
      #   .order("large_genres.order_no").count

      @search = @open_now.products.search
    end
  end

  def search
  end
end
