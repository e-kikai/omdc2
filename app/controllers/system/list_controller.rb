class System::ListController < System::ApplicationController
  # before_action :select_company_proudcuts, only: [:hangtag]
  # before_action :select_company_proudcuts_ef, only: [:ef]
  before_action :get_companies_selector, only: [:hangtag, :ef, :carryout_new, :carryout_edit]
  before_action :check_open
  before_action :check_entry_date
  before_action :get_product, only: [:edit, :update, :carryout_edit, :carryout_update, :carryout_destroy]
  before_action :get_selectors, only: [:new, :edit]

  include Exports

  def index
    @search    = @open_now.products.includes(:company, :area).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    @count         = @products.count
    @company_count = @products.distinct.count(:company_id)
    @min_price_sum = @products.sum(:min_price)

    respond_to do |format|
      format.html
      format.csv {
        @products  = @products.listed if params[:list_no].present?
        export_csv "products_list.csv"
      }
    end
  end

  def hangtag
    respond_to do |format|
      format.html
      format.pdf {
        if @company = Company.find_by(id: params[:company_id])
          @search   = @open_now.products.includes(:company).listed.where(company_id: params[:company_id]).search(params[:q])
        else
          # redirect_to({format: :html}, alert: "会社を選択して下さい")
          @search   = @open_now.products.includes(:company).listed.search(params[:q])
        end
        @products = @search.result.order("companies.no", :app_no)
        # export_pdf("hangtag.pdf", "/system/list/hangtag", margin_top: "0mm", margin_right: "0mm", margin_bottom: "0mm", margin_left: "0mm")
        format.pdf
      }
    end
  end

  def ef
    respond_to do |format|
      format.html
      format.pdf {
        if @company = Company.find_by(id: params[:company_id])
          # export_pdf
        else
          redirect_to({format: :html}, alert: "会社を選択して下さい")
        end
      }
    end
  end

  ### 入庫処理 ###
  def new
    # if params[:company_id].present?
    #   @products          = @open_now.products.includes(:company).where(company_id: params[:company_id]).order(:app_no)
    #   @products_selector = @products.order(:app_no).pluck("app_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id) if @products.present?
    # end

    key = params[:key].to_s.normalize_charwidth.gsub(/[―ー−‐]/, '-').strip
    if key =~ /^([0-9]+)\-([0-9]+)\-([0-9]+)$/
      product = Product.includes(:company).find_by(open_id: $1, companies: {no: $2}, app_no: $3)
      if product.blank?
        flash.now[:alert] =  "#{key} 商品情報がありません"
      else
        redirect_to "/system/list/#{product.id}/edit"
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
        p.list_no = (max_list_no +=1)
        p.save
      end
    end

    lp = list_no_params
    session[:system_area_id] = lp[:area_id]

    lp[:list_no] = @open_now.products.max_list_no + 1 if lp[:list_no].blank? # デフォルト値

    if @product.update(lp)
      redirect_to "/system/list/new", notice: "#{@product.name}をリストNo. #{@product.list_no}で入庫確認しました"
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
    redirect_to "/system/list/carryout/#{@product.id}", notice: "No. #{@product.list_no} : #{@product.name}の出庫確認しました"
  end

  def carryout_destroy
    @product.update(carryout_at: nil)
    redirect_to "/system/list/carryout/#{@product.id}", notice: "No. #{@product.list_no} : #{@product.name}の出庫をキャンセルしました"
  end

  ### 広告用CSV ###
  def ads
    @products = @open_now.products.includes(:company, :area).order(:list_no)

    respond_to do |format|
      format.csv { export_csv "ad_products_list.csv" }
    end
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
    @areas_selector    = Area.order(:order_no).pluck(:name, :id)
  end

  def list_no_params
    params.require(:product).permit(:list_no, :area_id)
  end
end
