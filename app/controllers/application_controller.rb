class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :get_open_now

  layout 'layouts/application'

  # ログイン後のリンク先
  def after_sign_in_path_for(resource)
    case resource
    when System; "/system/"
    else         "/bid/"
    end
  end

  # ログアウト後のリンク先
  def after_sign_out_path_for(resource)
    case resource
    when System; "/system/login"
    else         "/bid/login"
    end
  end

  private

  def get_open_now
    @open_now = Open.now.first
    @products = @open_now.products.listed if @open_now
  end

  def check_open
    redirect_to "/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_display
    unless @open_now.display?
      redirect_to "/", notice: "下見期間開始前です (下見期間 : #{@open_now.preview_start_date} 〜 #{@open_now.preview_end_date})"
    end
  end
end
