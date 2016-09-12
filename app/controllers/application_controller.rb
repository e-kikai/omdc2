class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action { @open_now = Open.now }

  layout 'layouts/application'

  def after_sign_in_path_for(resource)
    case resource
    when System
      "/system/"
    else
      "/bid/"
    end
  end

  def after_sign_out_path_for(resource)
    case resource
    when System
      "/system/login"
    else
      "/bid/login"
    end
  end
end
