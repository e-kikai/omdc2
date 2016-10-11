class Bid::BidsController < ApplicationController
  before_action :check_open
  before_action :check_entry_date, extract: [:index]
  before_action :bids

  def index
    @product = params[:list_no].present? ? @open_now.products.find_by(list_no: params[:list_no]) : nil
    @bid     = @product.bids.new(company: current_company) if @product
  end

  def create
    @bid = @bids.new(bid_params)
    if @bid.save
      redirect_to "/bid/bids/", notice: "#{@bid.product.name}に入札しました"
    else
      @bid = @open_now.products.find_by(id: bid_params[:product_id])
      render :index
    end
  end

  def results
    @products  = @open_now.products.order(params[:order] || :list_no)
    @pproducts = @products.page(params[:page])
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

  def check_entry_date
    redirect_to "/bid/", notice: "現在、入札期間ではありません" unless @open_now
  end

  def bids
    @bids = @open_now.bids.where(company: current_company)
  end

  def bid_params
    params.require(:bid).permit(:product_id, :amount, :comment)
  end
end
