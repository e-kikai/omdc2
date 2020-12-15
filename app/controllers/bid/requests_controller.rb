class Bid::RequestsController < Bid::ApplicationController
  before_action :check_open
  before_action :check_bid, only: [:index, :new, :update, :destroy]
  before_action :bid_init,  only: [:show, :update]


  def index
    @search   = @open_now.requests.where(company: current_company).includes(:product, :genre, :product_company).search(params[:q])

    @requests = @search.result.where(user_id: current_company.users).order(created_at: :desc)

    if params[:user_id].present?
      @user     = current_company.users.find(params[:user_id])
      @requests = @requests.where(user_id: params[:user_id])
    end
  end

  def new
  end

  def update
    if @bid.save
      @request.update(bided_at: Time.now)

      redirect_to "/bid/requests/", notice: "#{@request.user.company} #{@request.user.name}からの依頼に入札しました。\n\nNo. #{@product.list_no} : #{@product.name}"
    else
      render :new
    end
  end

  private

  def bid_init
    @request = current_company.requests.find(params[:id])
    @product = @open_now.products.find_by(list_no: @request.product[:list_no])
    @bid     = @product.bids.new(
      company: current_company,
      amount:  @request.amount,
      comment: "#{@request.user.company} #{@request.user.name}"
    ) if @product
  end

  def bid_params
    params.require(:bid).permit(:product_id, :amount, :comment)
  end

end
