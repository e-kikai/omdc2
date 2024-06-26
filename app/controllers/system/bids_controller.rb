class System::BidsController < System::ApplicationController
  before_action :check_open
  before_action :check_bid_start,   only: [:index, :new, :create, :destroy, :edit, :update, :destroy]
  before_action :check_result_list, only: [:results]
  before_action :check_result_sum,  only: [:rakusatsu_sum, :shuppin_sum, :total, :total_list]
  before_action :calc_result,       only: [:rakusatsu_sum, :shuppin_sum, :total, :total_list]

  before_action :get_companies_selector, except: [:results]
  before_action :bids, except: [:results]

  before_action :bid_init, only: [:new, :create]
  before_action :get_bid, only: [:edit, :update, :destroy]

  include Exports

  def index
    respond_to do |format|
      format.html
      format.pdf { export_pdf "#{@open_now.name}_bids.pdf", "/bid/bids/index.pdf" }
      format.csv { export_csv "#{@open_now.name}_bids.csv", "/bid/bids/index.csv" }
    end
  end

  def new
  end

  def create
    @bid.assign_attributes(bid_params)
    if params[:overcheck].to_i != @bid.amount && @over = @bid.check_5time
      render :new
    elsif @bid.present? && @bid.save
      redirect_to "/system/bids/new", notice: "#{@bid.product.name}に入札しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @bid.assign_attributes(bid_params)
    if params[:overcheck].to_i != @bid.amount && @over = @bid.check_5time
      render :edit
    elsif @bid.save
      redirect_to "/system/bids/", notice: "#{@bid.product.list_no} : #{@bid.product.name}の入札を訂正しました"
    else
      render :edit
    end
  end

  def rakusatsu_sum
    if @company
      @search   = @open_now.bids.where(company: @company).includes(:product, :genre, :success_bid).search(params[:q])
      @bids     = @search.result.order(:created_at)

      respond_to do |format|
        format.html
        format.pdf { export_pdf "rakusatsu.pdf", "/bid/bids/rakusatsu_sum.pdf" }
        format.csv { export_csv "rakusatsu.csv", "/bid/bids/rakusatsu_sum.csv" }
      end
    end
  end

  def shuppin_sum
    if @company
      @search   = @open_now.products.listed.where(company: @company).includes(:genre, :success_bid, :success_company).search(params[:q])
      @products = @search.result.order(:list_no)

      respond_to do |format|
        format.html
        format.csv { export_csv "shuppin.csv", "/bid/bids/shuppin_sum.csv" }
      end

    end
  end

  def total
    if @company
      @products         = @open_now.products.listed.where(company: @company).includes(:success_bid)
      @success_products = @open_now.bids.where(company: @company).includes(:product, :success_bid).success_products
    end
  end

  def destroy
    @bid.soft_destroy!
    redirect_to "/system/bids/", notice: "#{@bid.product.name}の入札を取り消しました"
  end

  def total_list
    all_products = @open_now.products.listed.includes(:success_bid, :success_company, :company)
    all_bids     = @open_now.bids.includes(:product, :success_bid, :product_company, :company)
    @companies = Company.order(:no)

    @company_products = @companies.map do |c|
      [
        c.id,
        {
          products:         all_products.where(company: c).order(:list_no),
          success_products: all_bids.where(company: c).success_products
        }
      ]
    end.to_h

    respond_to do |format|
      format.html
      # format.pdf { export_pdf "#{@open_now.name}_精算表.pdf" }
      format.pdf
      format.csv { export_csv "total.csv" }
    end
  end

  private

  def select_company_bids
    @companies = Company.order(:no).pluck("no || ' : ' || name", :id)

    session[:system_company_id] = params[:company_id] if params[:company_id].present?

    if session[:system_company_id].present? && @company = Company.find_by(id: session[:system_company_id])
      @search = @open_now.bids.where(company_id: session[:system_company_id]).search(params[:q])
      @bids   = @search.result
    else
      session[:system_company_id] = nil
      flash[:notice] = "会社を選択してください"
    end
  end

  def bids
    @search = @open_now.bids.where(company: @company).includes(:product, :genre).search(params[:q])
    @bids   = @search.result.order(created_at: :desc)
  end

  def bid_init
    @product = params[:list_no].present? ? @open_now.products.find_by(list_no: params[:list_no]) : nil
    @bid     = @product.bids.new(company: @company) if @product
  end

  def get_bid
    @bid = @bids.find(params[:id])
  end

  def calc_result
    @open_now.result_sum unless @open_now.result
  end

  def bid_params
    params.require(:bid).permit(:product_id, :amount, :comment)
  end
end
