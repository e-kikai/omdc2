class System::ListController < ApplicationController
  # before_action :select_company_proudcuts, only: [:hangtag]
  # before_action :select_company_proudcuts_ef, only: [:ef]
  before_action :get_companies_selector, only: [:hangtag, :ef]
  before_action :check_open
  before_action :check_entry_date
  before_action :get_product, only: [:edit, :update, :carry_out_update]
  before_action :get_selectors, only: [:new, :edit]

  include Exports

  def index
    @search    = @open_now.products.includes(:company, :area).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.csv {
        @products  = @products.listed
        export_csv
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
        export_pdf("hangtag.pdf", "/system/list/hangtag", margin_top: "0mm", margin_right: "0mm", margin_bottom: "0mm", margin_left: "0mm")
      }
    end
  end

  def ef
    respond_to do |format|
      format.html
      format.pdf {
        if @company = Company.find_by(id: params[:company_id])
          export_pdf
        else
          redirect_to({format: :html}, alert: "会社を選択して下さい")
        end
      }
    end
  end

  def new
    if params[:company_id].present?
      @products          = @open_now.products.includes(:company).where(company_id: params[:company_id]).order(:app_no)
      @products_selector = @products.order(:app_no).pluck("app_no || ' : ' || products.name || ' ' || coalesce(maker, '-') || ' ' || coalesce(model, '-')", :id) if @products.present?
    end
  end

  def edit
    # デフォルト値
    @product.list_no ||= @open_now.products.max_list_no + 1
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

    session[:system_area_id] = list_no_params[:area_id]

    if @product.update(list_no_params)
      redirect_to "/system/list/#{@product.id}/edit", notice: "#{@product.name}をリストNo. #{@product.list_no}で入庫確認しました"
    else
      render :list_no
    end
  end

  def qr_fin
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

  def carry_out_params
    params.require(:product).permit(:carryout_at)
  end
end
