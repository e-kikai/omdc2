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
    if @open_now
      @products = @open_now.products.listed
    end
  end
end
