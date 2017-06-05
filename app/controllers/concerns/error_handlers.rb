module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :rescue500
    rescue_from ApplicationController::Forbidden, with: :rescue403
    rescue_from ApplicationController::IpAddressRejected, with: :rescue403
    rescue_from ActionController::RoutingError, with: :rescue404
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404

    def routing_error
      raise ActionController::RoutingError, params[:path]
    end
  end

  private

  def rescue403(e)
    @exception = e
    render 'errors/error_403.html.slim', status: 403
  end

  def rescue404(e)
    @exception = e
    render 'errors/error_404.html.slim', status: 404
  end

  def rescue500(e)
    @exception = e
    render 'errors/error_500.html.slim', status: 500
  end
end
