class System::ProductsController < System::ApplicationController
  before_action :select_company_proudcuts
  before_action :check_open
  before_action :check_entry_date, extract: [:index]
  before_action :get_product, only: [:edit, :update, :destroy, :image_upload, :image_destroy, :images_order, :list_no, :list_no_update, :carry_out, :carry_out_update]

  include Exports

  def index
  end

  def new
    @product = @products.new if @company
  end

  def create
    @product = @products.new(product_params)
    if @product.save
      redirect_to "/system/products/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to "/system/products/", notice: "#{@product.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product.soft_destroy!
    redirect_to "/system/products/", notice: "#{@product.name}を削除しました"
  end

  def csv
  end

  def csv_upload
    redirect_to "/system/products/csv", alert: 'CSVファイルを選択してください' if params[:file].blank?

    @res = @products.import_conf(params[:file])
    redirect_to "/system/products/csv", alert: '商品情報がありませんでした' if @res.length == 0
  end

  def csv_import
    num = csv_products_params.length

    redirect_to "/system/products/csv", alert: '一括登録する商品がありません' if num == 0

    @products.import(csv_products_params)
    redirect_to("/system/products/", notice: "#{num.to_s}件の商品を一括登録しました")
  end

  def images
    @products = @products.includes(:product_images)
  end

  def image_upload
    product_image = @product.product_images.build
    begin
      ProductImage.transaction do
        product_image.save!
        product_image.update!(image: params[:image])
      end
      render status: 200, json: product_image
    rescue ActiveRecord::RecordInvalid
      render status: 500, json: product_image.errors.full_messages.to_s
    end
  end

  def images_order
    params[:images].each.with_index do |i, key|
      @product.product_images.find(i).update(order_no: (key + 1) * 10)
    end
  end

  def image_destroy
    @product.product_images.find(params[:product_image_id]).destroy
    respond_to do |format|
      format.html
      format.json { render :json =>  true }
    end
  end

  #############################################

  def carry_out
  end

  def carry_out_update
    if @product.update(carry_out_params)
      redirect_to "/system/products/qr_fin", notice: "#{@product.list_no} : #{@product.name}の出庫を確認しました"
    else
      render :list_no
    end
  end

  private

  def select_company_proudcuts
    @companies = Company.order(:no).pluck("no || ' : ' || name", :id)

    session[:system_company_id] = params[:company_id] if params[:company_id].present?

    if session[:system_company_id].present? && @company = Company.find_by(id: session[:system_company_id])
      @search   = @open_now.products.where(company_id: session[:system_company_id]).search(params[:q])
      @products = @search.result
    else
      session[:system_company_id] = nil
      flash[:notice] = "会社を選択してください"
    end
  end

  def check_open
    redirect_to "/system/", alert: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/system/", alert: "現在、出品期間ではありません" unless @open_now
  end

  def get_product
    @product = @products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama)
  end

  def csv_products_params
    params.require(:products).map { |p| p.permit(:name, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama)}
  end

end
