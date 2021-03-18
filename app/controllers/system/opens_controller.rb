class System::OpensController < System::ApplicationController
  before_action :get_open, only: [:show, :edit, :update, :destroy, :result_detail, :products, :detail_logs]

  include Exports

  def index
    @opens = Open.order(bid_end_at: :desc)
  end

  def new
    @open = Open.new
  end

  def create
    @open = Open.new(open_params)
    if @open.save
      redirect_to "/system/opens/", notice: "#{@open.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @open.update(open_params)
      redirect_to "/system/opens/", notice: "#{@open.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @open.soft_destroy!
    redirect_to "/system/opens/", notice: "#{@open.name}を削除しました"
  end

  def show
    redirect_to "/system/opens/", alert: "#{@open.name}はまだ終了していません" if @open.bid_end_at > Time.now

    @open.result_sum if !@open.result || params[:recalc].present? # 再計算を考慮

    @search    = @open.products.listed.includes(:success_bid, :success_company, :company, :genre, :large_genre, :xl_genre, :area, :product_images).search(params[:q])
    @products  = @search.result.order(:list_no).distinct
    @pproducts = @products.page(params[:page])

    @max_list_no = @open.products.listed.maximum(:list_no)

    respond_to do |format|
      format.html
      format.csv { export_csv "results.csv" }
    end
  end

  def result_detail
    @product = @open.products.includes(:bids, :success_bid).find(params[:product_id])
  end

  def products
    @products = @open.products.includes(:success_bid, :success_company, :company, :genre, :large_genre, :xl_genre, :area)

    respond_to do |format|
      format.csv {
        send_data render_to_string,
        content_type: 'text/csv',
        filename: filename_encode("#{@open.id}_products.csv")
      }
    end
  end

  def detail_logs
    @detail_logs = DetailLog
      .where(product_id: @open.products, created_at: @open.preview_start_date.beginning_of_day..@open.bid_end_at.end_of_day).group(:product_id).count

    ### 訪問者数 ###
    @detail_users = DetailLog.distinct
      .where(product_id: @open.products, created_at: @open.preview_start_date.beginning_of_day..@open.bid_end_at.end_of_day).group(:product_id).count(:ip)

    respond_to do |format|
      format.csv {
        send_data render_to_string,
        content_type: 'text/csv',
        filename: filename_encode("#{@open.id}_detail_logs.csv")
      }
    end
  end

  private

  def get_open
    @open = Open.find(params[:id])
  end

  def open_params
    params.require(:open).permit(:name, :entry_start_date, :entry_end_date, :carry_in_start_date, :carry_in_end_date, :preview_start_date, :preview_end_date, :bid_start_at, :bid_end_at, :user_bid_end_at, :carry_out_start_date, :carry_out_end_date, :billing_date, :payment_date, :lower_price, :rate, :tax, :product_rate)
  end
end
