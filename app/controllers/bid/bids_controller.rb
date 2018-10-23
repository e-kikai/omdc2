class Bid::BidsController < Bid::ApplicationController
  before_action :check_open
  before_action :check_bid,         only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :check_result_sum,  only: [:rakusatsu_sum, :shuppin_sum, :total, :motobiki]
  before_action :calc_result,       only: [:rakusatsu_sum, :shuppin_sum, :total, :motobiki]

  before_action :bids
  before_action :products, only: [:shuppin_sum, :total]

  before_action :bid_init, only: [:new, :create]
  before_action :get_bid, only: [:edit, :update, :destroy]

  include Exports

  def index
    respond_to do |format|
      format.html
      format.pdf { export_pdf "bids.pdf" }
      format.csv { export_csv "bids.csv" }
    end
  end

  def new
  end

  def create
    @bid.assign_attributes(bid_params)
    if params[:overcheck].to_i != @bid.amount && @over = @bid.check_5time
      render :new
    elsif @bid.present? && @bid.save
      redirect_to "/bid/bids/new", notice: "#{@bid.product.list_no} : #{@bid.product.name}に入札しました"
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
      redirect_to "/bid/bids/", notice: "#{@bid.product.list_no} : #{@bid.product.name}の入札を訂正しました"
    else
      render :edit
    end
  end

  def rakusatsu_sum
    @products = @products.order(:list_no)
    @bids     = @bids.reorder("products.list_no")
    @company  = current_company

    respond_to do |format|
      format.html
      format.pdf {
        if params[:hikitori]
          export_pdf "#{@open_now.name}_引取指図書.pdf", "/bid/bids/hikitori"
        else
          export_pdf "#{@open_now.name}_落札確認.pdf"
        end
      }
      format.csv { export_csv "rakusatsu.csv" }
    end
  end

  def shuppin_sum
    @products = @products.order(:list_no)
    @company  = current_company

    respond_to do |format|
      format.html
      format.csv { export_csv "shuppin.csv" }
    end
  end

  def total
    @products         = @products
    @success_products = @bids.success_products
  end

  def motobiki
    @search   = @open_now.products.listed.includes(:success_bid, :success_company, :area, :company).order(:list_no).search(params[:q])
    relation  = @search.result

    # @products = relation.where(company: current_company, display: "一般出品", success_bid_id: nil).or(relation.where(success_bid_id: Bid.where(company_id: current_company.id)))
    @products = relation.where(company: current_company, display: ["一般出品", "常設コマ", "単品預り"], success_bid_id: nil).or(relation.where(success_bid_id: Bid.where(company_id: current_company.id)))

    @company  = current_company

    respond_to do |format|
      format.html
      format.csv { export_csv "motobiki.csv" }
      format.pdf { export_pdf "motobiki.pdf" }
    end
  end

  def destroy
    @bid.soft_destroy!
    redirect_to "/bid/bids/", notice: "#{@bid.product.name}の入札を取り消しました"
  end

  private

  def bids
    @search = @open_now.bids.where(company: current_company).includes(:product, :genre, :success_bid, :product_company).search(params[:q])
    @bids   = @search.result.order(created_at: :desc)
  end

  def products
    @search   = @open_now.products.listed.where(company_id: current_company.id).includes(:success_bid, :success_company, :company, :genre, :large_genre, :xl_genre).search(params[:q])
    @products = @search.result
  end

  def bid_init
    @product = params[:list_no].present? ? @open_now.products.find_by(list_no: params[:list_no]) : nil
    @bid     = @product.bids.new(company: current_company) if @product
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
