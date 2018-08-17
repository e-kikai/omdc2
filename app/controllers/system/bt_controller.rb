class System::BtController < ApplicationController
  before_action :get_companies_selector, only: [:hangtag, :ef, :carryout_new, :carryout_edit]
  before_action :check_open
  before_action :check_entry_date
  before_action :get_product,   only: [:edit, :update, :carryout_edit, :carryout_update, :carryout_destroy]
  before_action :get_selectors, only: [:new, :edit]

  layout 'system/bt'

  def index

  end

  ### 入庫処理 ###
  def new
    # 入力キー変換
    key = params[:key].to_s.normalize_charwidth.gsub(/[―ー−‐]/, '-').strip

    if key =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)$/
      product = Product.includes(:company).find_by(open_id: $1, companies: {no: $2}, app_no: $3)
      if product.blank?
        flash.now[:alert] =  "#{key} 商品情報がありません"
      else
        redirect_to "/system/bt/#{product.id}/edit"
      end
    else
      flash.now[:alert] = "#{key} バーコードのフォーマットが違います" unless key.blank?
    end
  end

  def edit
    # @product.list_no ||= @open_now.products.max_list_no + 1 # デフォルト値

    @product.area_id ||= session[:system_area_id]

    @products          = @open_now.products.includes(:company).where(company_id: @product.company_id).order(:app_no)
    @products_selector = @products.order(:app_no).pluck("app_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id) if @products.present?
  end

  def update
    # 店頭出品の初期化
    if tento_products = @open_now.products.where(display: "店頭出品", list_no: nil).order(:company_id, :app_no)
      max_list_no = @open_now.products.max_list_no
      tento_products.each do |p|
        p.list_no = (max_list_no += 1)
        p.save
      end
    end

    lp = list_no_params
    session[:system_area_id] = lp[:area_id]

    lp[:list_no] = @open_now.products.max_list_no + 1 if lp[:list_no].blank? # デフォルト値

    if @product.update(lp)
      redirect_to "/system/bt/new", notice: "#{@product.name}をNo. #{@product.list_no}で入庫確認"
    else
      render :edit
    end
  end

  ### 出庫処理 ###
  def carryout_new
    if params[:company_id].present?
      relation   = @open_now.products.listed.includes(:success_bid).references(:bids).order(:list_no)

      @products_selector = relation.where(success_bid_id: Bid.where(company_id: params[:company_id]))
        .pluck("'(引取) ' || list_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id)

      @products_selector += relation.where(company_id: params[:company_id], display: "一般出品", success_bid_id: nil)
        .pluck("'(元引) ' || list_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id)
    end
  end

  def carryout_edit
    @company_id = @product.success_bid_id.present? ? @product.success_bid.company_id : @product.company_id

    relation   = @open_now.products.listed.includes(:success_bid).references(:bids).order(:list_no)

    @products_selector = relation.where(success_bid_id: Bid.where(company_id: @company_id))
      .pluck("'(引取) ' || list_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id)

    @products_selector += relation.where(company_id: @company_id, display: "一般出品", success_bid_id: nil)
      .pluck("'(元引) ' || list_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id)
  end

  def carryout_update
    @product.update(carryout_at: Time.now)
    redirect_to "/system/bt/carryout/#{@product.id}", notice: "No. #{@product.list_no} : #{@product.name}の出庫確認しました"
  end

  def carryout_destroy
    @product.update(carryout_at: nil)
    redirect_to "/system/bt/carryout/#{@product.id}", notice: "No. #{@product.list_no} : #{@product.name}の出庫をキャンセルしました"
  end

  private

  def check_open
    redirect_to "/system/", alert: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/system/", alert: "現在、出品期間ではありません" unless @open_now
  end

  def get_product
    @product = @open_now.products.find(params[:id])
  end

  def get_companies_selector
    @compaies_selector = Company.order(:no).pluck("no || ' : ' || name", :id)
  end

  def get_selectors
    get_companies_selector
    @areas_selector = Area.order(:order_no).pluck(:name, :id)
  end

  def list_no_params
    params.require(:product).permit(:list_no, :area_id)
  end
end