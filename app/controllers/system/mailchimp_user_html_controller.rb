class System::MailchimpUserHtmlController < System::ApplicationController
  Slim::Engine.options[:pretty] = true

  def index
    @open_selector  = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @info_selector = {
      '1. 開催案内' =>     :before,
      '2. 商品紹介' =>     :products,
      '3. 開催中'   =>     :now,
      '4. まもなく終了' => :soon,
    }

    @site_selector = {
      '機械団地入札会'         => :omdc,
      'マシンライフ'           => :machinelife,
      'ものづくりオークション' => :mnok
    }

    # 入札会情報
    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id  ? (@open_next&.id - 1) : @open_selector.first[1])
    @open    = Open.find @open_id

    # 配信対象ユーザ
    @site    = @site_selector.values.include?(params[:site]&.to_sym) ? params[:site]&.to_sym : @site_selector.first

    # 配信内容
    @info    = @info_selector.values.include?(params[:info]&.to_sym) ? params[:info]&.to_sym :  @info_selector.first

    # 顧客対応組合員
    @companies = Company.where(no: params[:company_nos].to_s.split).order(:no)

    if @info == :products
      @xl_genres = XlGenre.all

      @products = @open.products.listed.includes(:product_images).joins(:large_genre)
        .where.not(product_images: { id: nil }, large_genres: {name: "その他%"})

      # xl genres
      @prs = {}
      @xl_genres.each do |xl|
        ids = @products.where( large_genres: {xl_genre_id: xl.id}).distinct.pluck(:id).sample(9) # ランダム取得
        @prs[xl.id] = @products.where(id: ids).order(:list_no)
      end

      # all
      @prs_all = (1..9).map { |gid| @products.where( large_genres: {xl_genre_id: gid}).first }.compact
    else
      # その他の表示(ヘッダに3つだけ表示)
      ids = @open.products.listed.includes(:product_images).joins(:large_genre)
        .where.not(product_images: { id: nil }, large_genres: {name: "その他%"}).distinct.pluck(:id).sample(5)  # ランダム取得
      @prs_all = @products.where(id: ids).order(:list_no)
    end

    @rtag = params[:rtag].presence || "mail_maitest_o-#{@open_id}-#{@category}"
  end
end
