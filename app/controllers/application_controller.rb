class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :get_open_now
  before_action :make_utag

  layout "layouts/application_02"
  # layout 'layouts/application'

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  include ErrorHandlers if Rails.env.production? or Rails.env.staging?
  # include ErrorHandlers

  # ログイン後のリンク先
  def after_sign_in_path_for(resource)
    case resource
    when System; "/system/"
    when Company; "/bid/"
    else "/mypage/"
    end
  end

  # ログアウト後のリンク先
  def after_sign_out_path_for(resource)
    # case resource
    # when System; "/system/login"
    # else         "/bid/login"
    # end

    "/"
  end

  private

  def get_open_now
    ### ロボットの場合、セッションを開始しない ###

    ### 現在の入札会 ###
    @open_now = Open.now.first || Open.new
    @products = @open_now.products.listed.includes(:company, :genre, :large_genre, :xl_genre, :area, :product_images) if @open_now

    ### 次の入札会 ###
    @open_next = Open.next.first || Open.new

    ### 閲覧履歴 ###
    detail_logs = if user_signed_in?
        @user = current_user

        # IPからユーザ推測
        ips = DetailLog.where(user_id: current_user.id).distinct.pluck(:ip)
        ips << current_user.last_sign_in_ip.to_s
        ips << current_user.current_sign_in_ip.to_s

        ips.uniq

        DetailLog.where(user_id: current_user.id).or(DetailLog.where(ip: ips, user_id: nil))
      else
        DetailLog.where(ip: ip)
      end

    detail_logs = detail_logs.where(created_at: (1.year.ago)..(Time.now))

    @histories = @products.joins(:detail_logs).where("detail_logs.id": detail_logs).order("detail_logs.created_at": :desc, id: :asc).limit(5)
  end

  def check_open
    redirect_to "/", notice: "現在、入札会は開催されていません。" unless @open_now.persisted?
  end

  def check_display
    unless @open_now.display?
      redirect_to "/", notice: "下見期間開始前です (下見期間 : #{@open_now.preview_start_date} 〜 #{@open_now.preview_end_date})"
    end
  end

  def ip
    request.env["HTTP_X_FORWARDED_FOR"].split(",").first.strip || request.remote_ip
  end

  ### 未ログインユーザ追跡タグ生成 ###
  def make_utag
    session[:utag] = SecureRandom.alphanumeric(10) if session[:utag].blank?
  end
end
