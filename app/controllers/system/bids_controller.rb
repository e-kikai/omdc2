class System::BidsController < System::ApplicationController
  before_action :check_open
  before_action :check_entry_date, except: [:index]
  before_action :get_companies_selector, except: [:results]
  before_action :bids, except: [:results]
  before_action :bid_init, only: [:new, :create]

  include Exports

  def index
    respond_to do |format|
      format.html
      format.pdf { export_pdf "#{@open_now.name}_入札確認.pdf", "/bid/bids/index.pdf" }
      format.csv { export_csv "#{@open_now.name}_入札確認.csv", "/bid/bids/index.csv" }
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

  def results
    @search    = @open_now.products.includes(:bids).search(params[:q])
    @products  = @search.result.order(:list_no)
    @pproducts = @products.page(params[:page])
  end

  def rakusatsu_sum
    if @company
      @search   = @open_now.bids.where(company: @company).includes(:product, :genre, :success_bid).search(params[:q])
      @bids     = @search.result.order(:created_at)

      respond_to do |format|
        format.html
        format.pdf { export_pdf "#{@open_now.name}_落札確認.pdf", "/bid/bids/rakusatsu_sum.pdf" }
        format.csv { export_csv "#{@open_now.name}_落札確認.csv", "/bid/bids/rakusatsu_sum.csv" }
      end
    end
  end

  def shuppin_sum
    if @company
      @search   = @open_now.products.where(company: @company).includes(:genre, :success_bid).search(params[:q])
      @products = @search.result.order(:list_no)
    end
  end

  def total
    if @company
      @products         = @open_now.products.where(company: @company).includes(:success_bid)
      @success_products = @open_now.bids.where(company: @company).includes(:product, :success_bid).success_products
    end
  end

  def destroy
    @bid = @bids.find(params[:id])
    @bid.soft_destroy!
    redirect_to "/system/bids/", notice: "#{@bid.product.name}の入札を取り消しました"
  end

  def total_list
    all_products = @open_now.products.includes(:success_bid)
    all_bids     = @open_now.bids.includes(:product, :success_bid)
    @companies = Company.order(:no)

    @company_products = @companies.map do |c|
      [
        c.id,
        {
          products:         all_products.where(company: c),
          success_products: all_bids.where(company: c).success_products
        }
      ]
    end.to_h

    respond_to do |format|
      format.html
      format.pdf { export_pdf "#{@open_now.name}_集計一覧.csv" }
      format.csv { export_csv "#{@open_now.name}_集計一覧.csv" }
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

  def check_open
    redirect_to "/system/", notice: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/system/", notice: "現在、入札期間ではありません" unless @open_now
  end

  def bids
    @search = @open_now.bids.where(company: @company).includes(:product, :genre).search(params[:q])
    @bids   = @search.result.order(created_at: :desc)
  end

  def bid_init
    @product = params[:list_no].present? ? @open_now.products.find_by(list_no: params[:list_no]) : nil
    @bid     = @product.bids.new(company: @company) if @product
  end

  def bid_params
    params.require(:bid).permit(:product_id, :amount, :comment)
  end
end
