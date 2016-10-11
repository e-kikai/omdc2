class System::ProductsController < System::ApplicationController
  before_action :select_company

  def index
    @products = @company ? @company.products.order(:id) : []
  end

  def new
    @product = @company.products.new
  end

  def create
    @product = @company.products.new(product_params)
    if @product.save
      redirect_to "/system/companies/", notice: "#{@company.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    redirect_to "/system/products/" unless @product
    @product = @company.products.find(params[:id])
  end

  def update
    @product = @company.products.find(params[:id])
    if @product.update(product_params)
      redirect_to "/system/companies/", notice: "#{@company.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product = @company.products.find(params[:id])
    @product.soft_destroy!
    redirect_to "/system/products/", notice: "#{@product.name}を削除しました"
  end

  private

  def select_company
    @companies = Company.order(:no)

    unless @company = Company.find(params[:company_id])
      flash[:notice] = "会社を選択してください"
    end
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :comment, :min_price, :genre_id)
  end

end
