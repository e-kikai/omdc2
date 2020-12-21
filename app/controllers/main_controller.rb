class MainController < ApplicationController
  # skip_before_action :get_open_now, only: [:qrcode]
  before_action :check_open,    except: [:index]
  before_action :check_display, except: [:index]

  before_action :get_genres



  def index
    if @open_now
      # 特集
      @specials_01 = @products.where("min_price <= 10000").order("random()").limit(10)
      @specials_02 = @products.where("name ~ '一山|1山|雑品' OR hitoyama = true").order("random()").limit(10)
    end
  end

  def search
  end

  private

  ### ジャンル一覧用データ取得 ###
  def get_genres
    if @open_now
      @search = @open_now.products.listed.search

      @all_xl_counts    = @products.joins(:xl_genre).group("xl_genres.id", "xl_genres.name", "xl_genres.order_no").order("xl_genres.order_no").count
      @all_large_counts = @products.joins(:large_genre)
        .group("large_genres.id", "large_genres.xl_genre_id", "large_genres.name", "large_genres.order_no")
        .order("large_genres.order_no").count
    end
  end
end
