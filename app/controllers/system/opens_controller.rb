class System::OpensController < System::ApplicationController
  include Exports

  def index
    @opens = Open.order(:bid_end_at)
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
    @open = Open.find(params[:id])
  end

  def update
    @open = Open.find(params[:id])
    if @open.update(open_params)
      redirect_to "/system/opens/", notice: "#{@open.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @open = Open.find(params[:id])
    @open.soft_destroy!
    redirect_to "/system/opens/", notice: "#{@open.name}を削除しました"
  end

  def show
    @open      = Open.find(params[:id])
    redirect_to "/system/opens/", alert: "#{@open.name}はまだ終了していません" if @open.bid_end_at > Time.now

    @search    = @open.products.includes(:bids, :company, :genre, :large_genre, :xl_genre).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@open.name}_result.csv" }
    end
  end

  private

  def open_params
    params.require(:open).permit(:name, :entry_start_date, :entry_end_date, :carry_in_start_date, :carry_in_end_date, :preview_start_date, :preview_end_date, :bid_start_at, :bid_end_at, :user_bid_end_at, :carry_out_start_date, :carry_out_end_date, :billing_date, :payment_date, :lower_price, :rate, :tax)
  end
end
