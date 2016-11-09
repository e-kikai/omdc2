class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action {
    @open_now       = Open.now.first
    if @open_now
      @entry_products = @open_now.products
      @products       = @open_now.products.where.not(list_no: nil)
    end
  }

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
end
