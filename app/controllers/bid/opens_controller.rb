class Bid::OpensController < Bid::ApplicationController
  before_action :get_open, only: [:show]

  include Exports

  def index
    @opens = Open.order(bid_end_at: :desc)
  end

  def show
    redirect_to "/bid/opens/", alert: "#{@open.name}はまだ終了していません" if @open.bid_end_at > Time.now

    @open.result_sum unless @open.result

    @search    = @open.products.listed.with_keywords(params[:keywords])
      .includes(:success_bid, :success_company, :company, :genre, :product_images, :large_genre, :xl_genre, :area).search(params[:q])
    @products  = @search.result.order(:list_no).distinct
    @pproducts = @products.page(params[:page])

    @max_list_no = @open.products.listed.maximum(:list_no)

    @my_bids = current_company.bids.order(amount: :desc)

    respond_to do |format|
      format.html
      format.csv { export_csv "results.csv" }
    end
  end

  private

  def get_open
    @open = Open.find(params[:id])
  end
end
