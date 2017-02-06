class Bid::OpensController < Bid::ApplicationController
  before_action :get_open, only: [:show]

  include Exports

  def index
    @opens = Open.order(:bid_end_at)
  end

  def show
    redirect_to "/bid/opens/", alert: "#{@open.name}はまだ終了していません" if @open.bid_end_at > Time.now

    @search    = @open.products.includes(:bids, :company, :genre, :large_genre, :xl_genre).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open.name}_result.csv" }
    end
  end

  private

  def get_open
    @open = Open.find(params[:id])
  end
end
