class Bid::OpensController < Bid::ApplicationController
  before_action :get_open, only: [:show]

  include Exports

  def index
    @opens = Open.order(bid_end_at: :desc)
  end

  def show
    redirect_to "/bid/opens/", alert: "#{@open.name}はまだ終了していません" if @open.bid_end_at > Time.now

    @open.result_sum unless @open.result

    @search    = @open.products.listed.includes(:success_bid, :success_company, :company, :genre, :large_genre, :xl_genre).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    @max_list_no = @open.products.listed.maximum(:list_no)

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open.name}_落札結果一覧.csv" }
    end
  end

  private

  def get_open
    @open = Open.find(params[:id])
  end
end
