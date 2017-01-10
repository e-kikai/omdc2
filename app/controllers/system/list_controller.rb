class System::ListController < ApplicationController
  before_action :select_company_proudcuts, only: [:hangtag, :ef]
  before_action :check_open
  before_action :check_entry_date
  before_action :get_product, only: [:qr, :list_no, :list_no_update, :carry_out, :carry_out_update]

  include Exports

  def index
    @search    = @open_now.products.search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])
  end

  def hangtag
    respond_to do |format|
      format.html
      format.pdf { export_pdf }
    end
  end

  def ef
    respond_to do |format|
      format.html { render "ef.pdf.slim" }
      format.pdf { export_pdf }
    end
  end

  def qr
    data = RQRCode::QRCode.new("#{root_url}qr/#{@product.id}?place=#{params[:place]}", size: 4, level: :m).as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 70,
          border_modules: 0,
          module_px_size: 2,
          file: nil # path to write
          )

    respond_to do |format|
      format.png { send_data data, type: "image/png", disposition: 'inline' }
    end
  end

  def list_no
    @areas = Area.order(:order_no)
  end

  def list_no_update
    if @product.update(list_no_params)
      redirect_to "/system/products/qr_fin", notice: "#{@product.name}をリストNo. #{@product.list_no}で入庫確認しました"
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

  def select_company_proudcuts
    if params[:company_id].present? && @company = Company.find_by(id: params[:company_id])
      @search   = @open_now.products.listed.where(company_id: params[:company_id]).search(params[:q])
      @products = @search.result.order(:list_no)
    else
      @search   = @open_now.products.listed.search(params[:q])
      @products = @search.result.order(:list_no)
    end
  end

  def get_product
    @product = @open_now.products.find(params[:id])
  end


  def list_no_params
    params.require(:product).permit(:list_no, :area_id)
  end

  def carry_out_params
    params.require(:product).permit(:carryout_at)
  end
end
