class Bid::BidsController < Bid::ApplicationController
  before_action :check_open
  before_action :check_entry, extract: [:index]
  before_action :bids

  include Exports

  def index
    respond_to do |format|
      format.html
      format.pdf { export_pdf }
      format.csv { export_csv }
    end
  end

  def new
    @product = params[:list_no].present? ? @open_now.products.find_by(list_no: params[:list_no]) : nil
    @bid     = @product.bids.new(company: current_company) if @product
  end

  def create
    @bid = @bids.new(bid_params)
    if @bid.save
      redirect_to "/bid/bids/new", notice: "#{@bid.product.name}に入札しました"
    else
      @bid = @open_now.products.find_by(id: bid_params[:product_id])
      render :index
    end
  end

  def results
    @search    = @open_now.products.includes(:bids).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])
  end

  def rakusatsu_sum
    @search   = @open_now.bids.where(company: current_company).includes(:product, :genre, :success_bid).search(params[:q])
    @bids     = @search.result.order(:created_at)

    respond_to do |format|
      format.html
      format.pdf { export_pdf }
      format.csv { export_csv }
    end
  end

  def shuppin_sum
    @search   = @open_now.products.where(company: current_company).includes(:genre, :success_bid).search(params[:q])
    @products = @search.result.order(:list_no)
  end

  def total
    @products         = @open_now.products.where(company: current_company).includes(:success_bid)
    @success_products = @open_now.bids.where(company: current_company).includes(:product, :success_bid).success_products

  end

  def destroy
    @bid = @bids.find(params[:id])
    @bid.soft_destroy!
    redirect_to "/bid/bids/", notice: "#{@bid.product.name}の入札を取り消しました"
  end

  private

  def check_open
    redirect_to "/bid/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def bids
    @search = @open_now.bids.where(company: current_company).search(params[:q])
    @bids   = @search.result.order(created_at: :desc)
  end

  def bid_params
    params.require(:bid).permit(:product_id, :amount, :comment)
  end
end
