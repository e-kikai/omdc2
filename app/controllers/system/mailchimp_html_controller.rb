class System::MailchimpHtmlController < System::ApplicationController
  def index
    @open_selector  = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @category_selector = {
      '全体'      => :all,
      'NC'        => :nc,
      '一般'      => :normal,
      '鍛圧/鈑金' => :press,
      '工具'      => :tool
    }
    @site_selector = {
      '機械団地入札会'         => :omdc,
      'マシンライフ'           => :machinelife,
      'ものづくりオークション' => :mnok
    }


    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id  ? (@open_next&.id - 1) : @open_selector.first[1])
    @open = Open.find @open_id

    @category = @category_selector.values.include?(params[:category]&.to_sym) ? params[:category]&.to_sym : :all
    @site     = @site_selector.values.include?(params[:site]&.to_sym) ? params[:site]&.to_sym : :omdc

    xl_where = case @category
      when :nc;     1
      when :normal; 2
      when :press;  3..4
      when :tool;   7
      else;         1..100
    end

    @products = @open.products.listed.includes(:product_images).joins(:large_genre)
      .where( large_genres: {xl_genre_id: xl_where})
      .where.not(product_images: { id: nil }, large_genres: {name: "その他%"})

    @products = if @category == :all
      (1..9).map { |gid| @products.where( large_genres: {xl_genre_id: gid}).first }.compact
    else
      ids = @products.distinct.pluck(:id).sample(9) # ランダム取得
      @open.products.listed.includes(:product_images).where(id: ids).order(:list_no)
    end

    @rtag = params[:rtag].presence || "mail_maitest_o-#{@open_id}-#{@category}"
  end
end