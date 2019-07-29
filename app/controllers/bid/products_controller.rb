class Bid::ProductsController < Bid::ApplicationController
  before_action :check_open
  # before_action :check_entry,       except: [:index, :images, :image_upload, :images_order, :image_destroy, :sim]
  # before_action :check_entry_start, only:   [:index, :images, :image_upload, :images_order, :image_destroy]

  before_action :check_entry,       only: [:new, :create, :destroy, :csv, :csv_upload, :csv_import]
  before_action :check_entry_start, only: [:index, :edit, :update, :images, :image_upload, :images_order, :image_destroy]

  before_action :products,          except: [:sim]
  before_action :get_product,       only:   [:edit, :update, :destroy, :image_upload, :image_destroy, :images_order]

  skip_before_action :check_rule, only: [:sim]
  skip_before_action :authenticate_company!, only: [:sim]
  skip_before_action :check_default_password, only: [:sim]

  include Exports

  def index
    respond_to do |format|
      format.html
      format.csv {
        if params[:output] == "import"
          export_csv "update_products.csv", "/bid/products/import.csv"
        else
          export_csv "products.csv", "/bid/products/index.csv"
        end
      }
    end
  end

  def new
    @product = @products.new
    @product.genre_id = session[:new_genre_id]
  end

  def create
    @product = @products.new(product_params)
    if @product.save
      session[:new_genre_id] = @product.genre_id
      redirect_to "/bid/products/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    @only_update = true unless @open_now.entry?
  end

  def update
    res_params = @open_now.entry? ? product_params : only_update_params
    if @product.update(res_params)
      redirect_to "/bid/products/", notice: "#{@product.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@product.name}を削除しました"
  end

  def csv
  end

  def csv_upload
    redirect_to "/bid/products/csv", alert: 'CSVファイルを選択してください' if params[:file].blank?

    @res = @products.import_conf(params[:file])
    redirect_to "/bid/products/csv", alert: '商品情報がありませんでした' if @res.length == 0
  end

  def csv_import
    num = csv_products_params.length

    redirect_to "/bid/products/csv", alert: '一括登録する商品がありません' if num == 0

    @products.import(csv_products_params)
    redirect_to("/bid/products/", notice: "#{num.to_s}件の商品を一括登録しました")
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

  def sim
    if params[:min_price] && params[:amount]
      @product = @open_now.products.new({min_price: params[:min_price], display: "一般出品"})
      @product.bids.new({amount: params[:amount]})

      @errors = []
      @errors << "落札結果が最低入札金額より低く設定されています"     if params[:min_price].to_i > params[:amount].to_i
      @errors << "最低入札金額が最低出品金額より低く設定されています" if params[:min_price].to_i < @open_now.lower_price
      @errors << "最低入札金額が入札単位になっていません"             if params[:min_price].to_i % @open_now.rate != 0
      @errors << "落札結果が入札単位になっていません"                 if params[:amount].to_i % @open_now.rate != 0
    end
  end

  private

  def products
    @search   = @open_now.products.where(company_id: current_company.id).search(params[:q])
    @products = @search.result.order(app_no: :desc)
  end

  def get_product
    @product = @products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama)
  end

  def only_update_params
    params.require(:product).permit(:condition, :comment, :youtube, :hitoyama)
  end

  def csv_products_params
    params.require(:products).map { |p| p.permit(:app_no, :name, :maker, :model, :year, :spec, :condition, :comment, :min_price, :genre_id, :youtube, :display, :hitoyama, :soft_destroyed_at)}
  end
end
