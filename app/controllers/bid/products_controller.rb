class Bid::ProductsController < Bid::ApplicationController
  before_action :check_open
  before_action :check_entry_date, extract: [:index]
  before_action :products

  def index
  end

  def new
    @product = @products.new
  end

  def create
    @product = @products.new(product_params)
    if @product.save
      redirect_to "/bid/products/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    @product = @products.find(params[:id])
  end

  def update
    @product = @products.find(params[:id])
    if @product.update(product_params)
      redirect_to "/bid/products/", notice: "#{@product.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product = @products.find(params[:id])
    @product.soft_destroy!
    redirect_to "/bid/products/", notice: "#{@product.name}を削除しました"
  end

  def ml_get_genre
    @genre_id = Product.ml_get_genre(params[:product])

    respond_to do |format|
      format.html { render plain: @genre_id.to_s}
      format.js { }
    end
  end

  def imgs
  end

  def pdf_test
    respond_to do |format|
      format.html
      format.pdf do
        # 詳細画面のHTMLを取得
        html = render_to_string template: "/bid/products/pdf_test.html.slim"

        # PDFKitを作成
        kit = PDFKit.new(html, encoding: "UTF-8")
        kit.stylesheets << "/usr/local/rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/rails-assets-bootstrap-3.3.7/app/assets/stylesheets/bootstrap/bootstrap.scss"
        # kit = PDFKit.new("http://192.168.33.110:8082/bid/products/pdf_test", encoding: "UTF-8")

        # 画面にPDFを表示する
        # to_pdfメソッドでPDFファイルに変換する
        # 他には、to_fileメソッドでPDFファイルを作成できる
        # disposition: "inline" によりPDFはダウンロードではなく画面に表示される
        send_data kit.to_pdf,
          filename:    "pdf_test.pdf",
          type:        "application/pdf",
          disposition: "inline"
      end
    end
  end

  private

  def check_open
    redirect_to "/bid/", alert: "現在、開催されている入札会はありません" unless @open_now
  end

  def check_entry_date
    redirect_to "/bid/", alert: "現在、出品期間ではありません" unless @open_now
  end

  def products
    @products = @open_now.products.where(company_id: current_company.id)
  end

  def product_params
    params.require(:product).permit(:name, :list_no, :maker, :model, :year, :spec, :comment, :min_price, :genre_id, :youtube, :display)
  end
end
