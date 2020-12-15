class Mypage::ProductsController < Mypage::ApplicationController
  include Exports

  def index
    @products = @open_now.products.order(:list_no)

    respond_to do |format|
      format.csv { export_csv "#{@open_now.name}_products.csv" }
    end
  end
end
