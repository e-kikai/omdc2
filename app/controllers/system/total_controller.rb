class System::TotalController < System::ApplicationController
  include Exports

  def index
    @open_selector  = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @total_selector = {
        "検索方法/詳細アクセス、一山"  => :search_hitoyama_by_period,
        "リンク元/詳細アクセス、一山"  => :links_hitoyama_by_period,
        "出品会社/デメ半手数料"     => :company_deme,
        "価格帯/落札結果金額"      => :price_amount,
        "日別/アクセス,お気に入り利用" => :date_favorite,
        # "エリア/出品・落札結果金額"   => :area_amount,
        # "ジャンル/出品・落札結果金額"  => :genre_amount,
        "目玉商品/結果一覧"       => :feature_products,
    }

    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id ? (@open_next&.id - 1) : @open_selector.first[1])
    @total   = params[:total] || @total_selector.first[1]
    @title   = "#{@open_selector.to_h.key(@open_id.to_i)} - #{@total_selector.key(@total.to_sym)}"

    target = if @total =~ /by_period/
        open = Open.find(@open_id)
        [make_sql(@total), open.bid_start_at.beginning_of_day, open.bid_end_at.end_of_day]
      else
        [make_sql(@total), @open_id]
      end

    sanitize_sql = ActiveRecord::Base.send(:sanitize_sql_array, target)
    @result = ActiveRecord::Base.connection.select_all(sanitize_sql)

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@total}_#{@title.gsub(/[^\d]/, "")}.csv" }
    end
  end

  def index2
    @open_selector  = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @total_selector = {
        # "検索方法/詳細アクセス、一山"  => :search_hitoyama_by_period,
        # "リンク元/詳細アクセス、一山"  => :links_hitoyama_by_period,
        # "出品会社/デメ半手数料"     => :company_deme,
        # "価格帯/落札結果金額"      => :price_amount,
        # "日別/アクセス,お気に入り利用" => :date_favorite,
        "ジャンル/出品・落札結果金額" => :genre_amount,
        "エリア/出品・落札結果金額"   => :area_amount,
        # "目玉商品/結果一覧"       => :feature_products,
        "目玉商品 - ジャンル/出品・落札結果金額" => :feature_genre_amount,
    }

    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id ? (@open_next&.id - 1) : @open_selector.first[1])
    @total   = (params[:total] || @total_selector.first[1]).to_sym

    @title   = "#{@open_selector.to_h.key(@open_id.to_i)} - #{@total_selector.key(@total.to_sym)}"

    @results = case @total
    when :area_amount
      areas = Area.order(:order_no)
      products = Product.where(open_id: @open_id).group(:area_id)

      @pivots = areas.pluck(:id)

      products_count = products.count

      {
        "エリア" => areas.pluck(:id, :name).to_h,
        "出品商品数"       => products_count,
      }
    when :feature_genre_amount
      large_genres = LargeGenre.joins(:xl_genre).order("xl_genres.order_no, large_genres.order_no")
      products = Product.where(open_id: @open_id).joins(:genre).group("genres.large_genre_id")
      base_count = products.count

      products = products.where(featured: true) # 目玉商品

      @pivots = large_genres.pluck(:id)

      products_count = products.count

      {
        "大ジャンル"       => large_genres.pluck(:id, "xl_genres.name").to_h,
        "中ジャンル"       => large_genres.pluck(:id, :name).to_h,
        "目玉商品出品数"     => products_count,
        "目玉商品出品率(%)"  => percents(base_count, products_count),
      }
    else
      large_genres = LargeGenre.joins(:xl_genre).order("xl_genres.order_no, large_genres.order_no")
      products = Product.where(open_id: @open_id).joins(:genre).group("genres.large_genre_id")

      @pivots = large_genres.pluck(:id)

      products_count = products.count

      {
        "大ジャンル" => large_genres.pluck(:id, "xl_genres.name").to_h,
        "中ジャンル" => large_genres.pluck(:id, :name).to_h,
        "出品商品数"       => products_count,
      }
    end

    # 共通部分
    success_count  = products.count(:success_bid_id)

    @results.update({
      "最低入札価格総額(円)" => products.sum(:min_price),
      "出品会社数"       => products.distinct.count(:company_id),
      "詳細閲覧件数"        => products.joins(:detail_logs).count("detail_logs.id"),
      "お気に入り件数"       => products.joins(:favorites).count("favorites.id"),
      "入札数"         => products.sum(:bids_count),
      "落札数"         => success_count,
      "落札率(%)"      => percents(products_count, success_count),
      "落札金額合計(円)"   => products.joins(:success_bid).sum("bids.amount"),
    })

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@total}_#{@title.gsub(/[^\d]/, "")}.csv" }
    end
  end

  def opens
    @total_selector = {
      "指標目標"            => :goal,
      "アクセス,お気に入り" => :favorites,
      "目玉商品"            => :features,
    }
    @total = (params[:total] || @total_selector.first[1]).to_sym

    start_open_id = case @total
    when :features;  67
    when :favorites; 62
    else;            0
    end

    # 入札会一覧
    opens_base = Open.where("opens.id >= ?", start_open_id).order(:id)
    @opens = opens_base.pluck(:id, :name)
    @title = @total_selector.key(@total)

    products = Product.group(:open_id)

    @results = case @total
      when :features
        featured = products.where(featured: true)

        {
          "目玉商品出品数"    => featured.count,
          "目玉商品出品率(%)" => percents(products.count, featured.count),
          "最低金額"       => featured.sum(:min_price),
          "出品会社数"      => featured.distinct.count(:company_id),
          "詳細閲覧"       => featured.joins(:detail_logs).count("detail_logs.id"),
          "お気に入り"      => featured.joins(:favorites).count("favorites.id"),
          "入札数"        => featured.sum(:bids_count),
          "落札数"        => featured.count(:success_bid_id),
          "落札率(%)"     => percents(featured.count, featured.count(:success_bid_id)),
          "落札金額"       => featured.joins(:success_bid).sum("bids.amount"),
        }
      when :favorites
        details   = products.joins(:detail_logs)
        favorites = products.joins("INNER JOIN favorites ON favorites.product_id = products.id")
        deletes   = favorites.where("favorites.soft_destroyed_at IS NOT NULL")
        pdfs      = favorites.where("favorites.amount IS NOT NULL")

        {
          "ユーザ(累計)" => opens_base
            .joins("LEFT JOIN users ON users.created_at < opens.bid_end_at")
            .where("users.confirmed_at IS NOT NULL").group(:id).count("users.id"),
          "ユーザ(新規)" => opens_base
            .joins("LEFT JOIN users ON users.created_at BETWEEN opens.bid_start_at AND opens.bid_end_at")
            .where("users.confirmed_at IS NOT NULL").group(:id).count("users.id"),

          "出品数"          => products.count,
          "詳細(件)"        => details.count("detail_logs.id"),
          "詳細(utag)"     => details.distinct.count("detail_logs.utag"),
          "詳細(ログイン人)"    => details.distinct.count("detail_logs.user_id"),
          "詳細(商品数)"      => details.distinct.count("detail_logs.product_id"),
          "お気に入り(件)"     => favorites.count("favorites.id"),
          "お気に入り(人)"     => favorites.distinct.count("favorites.user_id"),
          "お気に入り(商品)"    => favorites.distinct.count("favorites.product_id"),
          "うち、削除(件)"     => deletes.count("favorites.id"),
          "うち、削除(人)"     => deletes.distinct.count("favorites.user_id"),
          "うち、PDF生成(件)"  => pdfs.count("favorites.id"),
          "うち、PDF生成(人)"  => pdfs.distinct.count("favorites.user_id"),
          "うち、PDF生成(商品)" => pdfs.distinct.count("favorites.product_id"),
        }
      else
        hitoyama = products.where("products.hitoyama = 'true' OR products.name ~ '(一山|1山|雑品)'")

        product_details = products.joins(:detail_logs).count("detail_logs.id")
        hitoyama_details = hitoyama.joins(:detail_logs).count("detail_logs.id")

        {
          "出品数"         => products.count,
          "出品最低入札価格(円)" => products.sum(:min_price),
          "出品会社数"       => products.distinct.count(:company_id),
          "落札金額(円)"     => products.joins(:success_bid).sum("bids.amount"),
          "落札数"         => products.count(:success_bid_id),
          "入札数"         => products.sum(:bids_count),
          "落札率(%)"      => percents(products.count, products.count(:success_bid_id)),
          "一山出品数"       => hitoyama.count,
          "一山出品率(%)"    => percents(products.count, hitoyama.count),
          "utag数"       => products.joins(:detail_logs).distinct.count("detail_logs.utag"),
          "詳細閲覧"        => product_details,
          "一山閲覧"        => hitoyama_details,
          "一山閲覧率(%)"    => percents(product_details, hitoyama_details),
        }
      end

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@total}_#{Time.now.strftime("%Y%m%d")}.csv" }
    end
  end

  def formula
    @open_selector = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id ? (@open_next&.id - 1) : @open_selector.first[1])
    @open = Open.find(@open_id)

    @company_selector = ["入札会全体", nil] + Company.order(:no).pluck("no || ' : ' || name", :id)
    @company_id = params[:company_id]

    # 条件作成
    products     = @open.products.includes(:company, :area)
    details      = products.joins(:detail_logs)
    bids         = products.joins(:bids)
    success_bids = products.joins(:success_bid)
    favorites    = products.joins("INNER JOIN favorites ON favorites.product_id = products.id")
    deletes      = favorites.where("favorites.soft_destroyed_at IS NOT NULL")
    pdfs         = favorites.where("favorites.amount IS NOT NULL")
    featured     = products.where(featured: true)

    if @company_id # 会社ごと
      @company             = Company.find(@company_id)
      company_products     = products.where(company_id: @company_id)
      company_details      = company_products.joins(:detail_logs)
      company_bids         = company_products.joins(:bids) # 出品会社
      company_success_bids = company_products.joins(:success_bid)
      company_favorites    = company_products.joins("INNER JOIN favorites ON favorites.product_id = products.id")
      company_deletes      = company_favorites.where("favorites.soft_destroyed_at IS NOT NULL")
      company_pdfs         = company_favorites.where("favorites.amount IS NOT NULL")
      company_featured     = company_products.where(featured: true)
      company_buys         = bids.where("bids.company_id" => @company_id) # 入札側
      company_success_buys = success_bids.where("bids.company_id" => @company_id)

      @results = {
        # 出品会社
        "出品数" => company_products.count,
        "出品最低入札価格合計" => company_products.sum(:min_price),

        "入札された件数" => company_products.sum(:bids_count),
        "入札された会社数" => company_bids.distinct.count("bids.company_id"),
        "落札された件数" => company_products.count(:success_bid_id),
        "落札された金額" => company_success_bids.sum("bids.amount"),

        "商品詳細閲覧件数" => company_details.count("detail_logs.id"),
        "商品詳細閲覧したユニークユーザ" => company_details.distinct.count("detail_logs.utag"),
        "商品詳細閲覧したログインユーザ" => company_details.distinct.count("detail_logs.user_id"),
        "商品詳細閲覧された商品数" => company_details.distinct.count("detail_logs.product_id"),

        "お気に入り件数"     => company_favorites.count("favorites.id"),
        "お気に入り利用ユーザ"  => company_favorites.distinct.count("favorites.user_id"),
        "お気に入りされた商品数" => company_favorites.distinct.count("favorites.product_id"),

        "お気に入りのうち、削除された件数" => company_deletes.count("favorites.id"),
        "お気に入りのうち、削除したユーザ" => company_deletes.distinct.count("favorites.user_id"),
        "お気に入りのうち、PDF生成件数" => company_pdfs.count("favorites.id"),
        "お気に入りのうち、PDF生成したユーザ" => company_pdfs.distinct.count("favorites.user_id"),
        "お気に入りのうち、PDF生成された商品数" => company_pdfs.distinct.count("favorites.product_id"),

        "目玉商品の出品数" => company_featured.count,
        "目玉商品の出品最低入札価格合計" => company_featured.sum(:min_price),
        "目玉商品の商品詳細閲覧件数" => company_featured.joins(:detail_logs).count("detail_logs.id"),
        "目玉商品のお気に入り件数" => company_featured.joins(:favorites).count("favorites.id"),
        "目玉商品の入札数" => company_featured.sum(:bids_count),
        "目玉商品の落札数" => company_featured.count(:success_bid_id),
        "目玉商品の落札金額" => company_featured.joins(:success_bid).sum("bids.amount"),

        # 入札側
        "入札した件数" => company_buys.sum(:bids_count),
        "落札した件数" => company_success_buys.count,
        "落札した金額" => company_success_buys.sum("bids.amount"),
      }
    else # 全体
      @results = {
        "出品数" => products.count,
        "出品最低入札価格合計" => products.sum(:min_price),
        "出品会社数" => products.distinct.count(:company_id),

        "入札数" => products.sum(:bids_count),
        "入札した会社数" => bids.distinct.count("bids.company_id"),
        "落札数" => products.count(:success_bid_id),
        "落札金額" => success_bids.sum("bids.amount"),
        "落札した会社数" => success_bids.distinct.count("bids.company_id"),
        "落札された出品会社数" => products.where.not(success_bid_id: nil).distinct.count(:company_id),

        "商品詳細閲覧件数" => details.count("detail_logs.id"),
        "商品詳細閲覧したユニークユーザ" => details.distinct.count("detail_logs.utag"),
        "商品詳細閲覧したログインユーザ" => details.distinct.count("detail_logs.user_id"),
        "商品詳細閲覧された商品数" => details.distinct.count("detail_logs.product_id"),

        "お気に入り件数" => favorites.count("favorites.id"),
        "お気に入り利用ユーザ" => favorites.distinct.count("favorites.user_id"),
        "お気に入りされた商品数" => favorites.distinct.count("favorites.product_id"),

        "お気に入りのうち、削除された件数" => deletes.count("favorites.id"),
        "お気に入りのうち、削除したユーザ" => deletes.distinct.count("favorites.user_id"),
        "お気に入りのうち、PDF生成件数" => pdfs.count("favorites.id"),
        "お気に入りのうち、PDF生成したユーザ" => pdfs.distinct.count("favorites.user_id"),
        "お気に入りのうち、PDF生成された商品数" => pdfs.distinct.count("favorites.product_id"),

        "目玉商品の出品数" => featured.count,
        "目玉商品の出品最低入札価格合計" => featured.sum(:min_price),
        "目玉商品の出品会社数" => featured.distinct.count(:company_id),
        "目玉商品の商品詳細閲覧件数" => featured.joins(:detail_logs).count("detail_logs.id"),
        "目玉商品のお気に入り件数" => featured.joins(:favorites).count("favorites.id"),
        "目玉商品の入札数" => featured.sum(:bids_count),
        "目玉商品の落札数" => featured.count(:success_bid_id),
        "目玉商品の落札金額" => featured.joins(:success_bid).sum("bids.amount"),
      }
    end

    @company = Company.find(@company_id) if @company_id
    products = @open.products.includes(:company, :area)
  end

  private

  def make_sql(total)
    case total.to_sym
    when :company_deme
      %q|
SELECT
  co.id,
  co."no" AS "会社No.",
  co.name AS "会社名",
  count(pr.*) AS "落札数",
  sum(sb.amount) AS "落札金額",
  sum((sb.amount - pr.min_price) / 2) AS "デメ半",
  sum(pr.min_price / 100 * (CASE WHEN pr.min_price <= 1000000 THEN 10 WHEN pr.min_price <= 2000000 THEN 8 WHEN pr.min_price <= 3000000 THEN 7 ELSE 5 END)) AS "販売手数料",
  sum(pr.min_price / 100 * (CASE WHEN pr.min_price <= 1000000 THEN 5 WHEN pr.min_price <= 1000000 THEN 4 ELSE 3 END)) AS "組合手数料"
FROM
  products pr
LEFT JOIN bids sb ON
  sb.id = pr.success_bid_id
LEFT JOIN companies co ON
  co.id = sb.company_id
WHERE
  pr.open_id = ?
  AND pr.success_bid_id IS NOT NULL
  AND pr.soft_destroyed_at IS NULL
GROUP BY
  co.id,
  co.name
ORDER BY
  co."no" ;
|
    when :search_hitoyama_by_period
      %q|
SELECT
  CASE
    WHEN sl.path ~ 'image_vector_search_by_file' THEN '画像ファイルからさがす'
    WHEN sl.path ~ 'image_vector_search' THEN '画像特徴ベクトル検索'
    WHEN sl.path ~ 'xl_genre' THEN '大ジャンル'
    WHEN sl.path ~ 'large_genre' THEN '中ジャンル'
    WHEN sl.path ~ 'genre' THEN 'ジャンル'
    WHEN sl.path ~ 'special/1' THEN '1万円以下特集'
    WHEN sl.path ~ 'special/2' THEN '1山特集'
    WHEN sl.path ~ 'list_no' THEN 'リストNo.からさがす'
    WHEN sl.path ~ 'keywords' THEN 'キーワード検索'
    WHEN sl.path ~ 'min_price_gteq' THEN '最低入札価格からさがす'
    ELSE sl.PATH
  END AS "リンク元",
  count(DISTINCT sl.ip) as "人数(IP)",
  count(DISTINCT sl.utag) as " 人数(utag)",
  count(*) AS "アクセス数(件)",
  ROUND( count(*) * 100 / SUM(count(*)) OVER (), 2) AS "割合(%)",
  sum(CASE WHEN sl.page = '1' THEN 1 END) AS "検索回数",
  ROUND( sum(CASE WHEN sl.page = '1' THEN 1 END) * 100 / SUM(sum(CASE WHEN sl.page = '1' THEN 1 END)) OVER (), 2) AS "検索回数割合"
FROM
  search_logs sl
WHERE
  sl.created_at BETWEEN ? AND ?
  AND host NOT LIKE '%google%'
GROUP BY
  "リンク元"
ORDER BY
  "アクセス数(件)" DESC ,
  "リンク元" DESC
|
    when :links_hitoyama_by_period
      %q{
        SELECT
    CASE
      WHEN dl.r ~ 'hist' THEN '閲覧履歴'
      WHEN dl.r ~ 'nms' THEN '画像特徴ベクトル検索'
      WHEN dl.r ~ 'mnf' THEN '画像ファイルからさがす'
      WHEN dl.r ~ 'qr' THEN 'QRコード'
      WHEN dl.r ~ 'fav' THEN 'お気に入りリスト'
      WHEN dl.r ~ 'reload' THEN 'ブラウザリロード'
      WHEN dl.r ~ 'dtl_nmr' THEN '詳細似た商品'
      WHEN dl.r ~ 'dtl_sge' THEN '詳細同じカテゴリ'
      WHEN dl.r ~ 'back' THEN 'ブラウザ履歴(進む・戻る)'
      WHEN dl.r ~ 'top_spc_01' THEN 'トップ1万円特集'
      WHEN dl.r ~ 'top_spc_02' THEN 'トップ一山特集'
      WHEN dl.r ~ 'xgn' THEN '大ジャンル検索'
      WHEN dl.r ~ 'lgn' THEN '中ジャンル検索'
      WHEN dl.r ~ 'gnl' THEN 'ジャンル検索'
      WHEN dl.r ~ 'lno' THEN 'リストNo.からさがす'
      WHEN dl.r ~ 'src_spc' THEN '特集一覧'
      WHEN dl.r ~ 'src'
      AND referer ~ 'products.*keywords' THEN 'キーワード検索'
      WHEN dl.r ~ 'src'
      AND referer ~ 'products.*min_price' THEN '最低入札価格検索'
      WHEN dl.r ~ 'src' THEN '検索結果(不明)'
      WHEN dl.r ~ '^$' THEN 'rなし(外部、直接ほか)'
      ELSE dl.r
    END as "リンク元",
    count(DISTINCT ip) as "人数(IP)",
    count(DISTINCT utag) as " 人数(utag)",
    count(*) AS "アクセス数(件)",
    ROUND( count(*) * 100 / SUM(count(*)) OVER (), 2) AS "割合(%)",
    sum(CASE WHEN pr.hitoyama = 'true' OR pr.name ~ '(一山|1山|雑品)' THEN 1 END) AS "うち一山(件)",
    ROUND( sum(CASE WHEN pr.hitoyama = 'true' OR pr.name ~ '(一山|1山|雑品)' THEN 1 END) * 100 / SUM(count(*)) OVER (), 2) AS "全体からの一山(%)"
  FROM
    detail_logs dl
  LEFT JOIN products pr ON
    pr.id = dl.product_id
  WHERE
    dl.created_at BETWEEN ? AND ?
    AND host NOT LIKE '%google%'
  GROUP BY
    "リンク元"
  ORDER BY
    "アクセス数(件)" DESC;
}
    when :price_amount
      %q{
      SELECT
  '〜 ' || CEIL(pr.min_price * 1.0 / 10000) * 10000 AS "最低価格の価格帯",
  count(*) AS "出品数",
  sum(pr.bids_count) AS "入札数",
  ROUND(sum(pr.bids_count) * 100 / sum(sum(pr.bids_count)) OVER(), 2) AS "入札数割合(%)",
  count(pr.success_bid_id) AS "落札数",
  ROUND(count(pr.success_bid_id)* 1.0 * 100 / count(*), 2) AS "落札率(%)",
  ROUND(count(pr.success_bid_id) * 100 / sum(count(pr.success_bid_id)) OVER(), 2) AS "落札数割合(%)",
  sum(sb.amount) AS "落札金額合計",
  ROUND(sum(sb.amount) * 100 / sum(sum(sb.amount)) OVER(), 2) AS "金額割合(%)",
  CEIL(pr.min_price * 1.0 / 10000) AS order_no
FROM
  products pr
LEFT JOIN bids sb ON
  sb.id = pr.success_bid_id
WHERE
  pr.open_id = ?
GROUP BY
  "最低価格の価格帯",
  order_no
ORDER BY
  order_no
    }
    when :date_favorite
      %q{
SELECT
  d.date,
  COALESCE(tb1.cnt, 0) AS "ユーザ登録",
  COALESCE(tb3.cnt, 0) AS "詳細アクセス(件)",
  COALESCE(tb3.utag_cnt, 0) AS "詳細アクセス(utag)",
  COALESCE(tb3.usr, 0) AS "詳細アクセス(ログイン人)",
  COALESCE(tb3.p_cnt, 0) AS "詳細アクセス(商品)",
  COALESCE(tb2.cnt, 0) AS "お気に入り(件)",
  COALESCE(tb2.usr, 0) AS "お気に入り(人)",
  COALESCE(tb2.p_cnt, 0) AS "お気に入り(商品)",
  COALESCE(tb4.cnt, 0) AS "PDF(件)",
  COALESCE(tb4.usr, 0) AS "PDF(人)",
  COALESCE(tb4.p_cnt, 0) AS "PDF(商品)",
  COALESCE(tb5.cnt, 0) AS "削除(件)",
  COALESCE(tb5.usr, 0) AS "削除(人)"
FROM
  (
    SELECT
      date(
        generate_series(o.carry_in_end_date::date, o.bid_end_at, '1 day')
      ) AS date
    FROM
      opens o
    WHERE
      o.id = ?
  ) d
LEFT JOIN
  (
    SELECT
      date(u.created_at) AS date,
      count(*) AS cnt
    FROM
      users u
    WHERE
      u.confirmed_at IS NOT NULL
    GROUP BY
      date
  ) tb1 ON
  tb1.date = d.date
LEFT JOIN
  (
    SELECT
      date(f.created_at) AS date,
      count(*) AS cnt,
      count(DISTINCT f.user_id) AS usr,
      count(DISTINCT f.product_id) AS p_cnt
    FROM
      favorites f
    GROUP BY
      date
  ) tb2 ON
  tb2.date = d.date
LEFT JOIN
  (
    SELECT
      date(dl.created_at) AS date,
      count(*) AS cnt,
      count(DISTINCT dl.utag) AS utag_cnt,
      count(DISTINCT dl.user_id) AS usr,
      count(DISTINCT dl.product_id) AS p_cnt
    FROM
      detail_logs dl
    GROUP BY
      date
  ) tb3 ON
  tb3.date = d.date
LEFT JOIN
  (
    SELECT
      date(f.created_at) AS date,
      count(*) AS cnt,
      count(DISTINCT f.user_id) AS usr,
      count(DISTINCT f.product_id) AS p_cnt
    FROM
      favorites f
    WHERE
      f.amount IS NOT NULL
    GROUP BY
      date
  ) tb4 ON
  tb4.date = d.date
LEFT JOIN
  (
    SELECT
      date(f.created_at) AS date,
      count(*) AS cnt,
      count(DISTINCT f.user_id) AS usr,
      count(f.amount) AS amount_cnt
    FROM
      favorites f
    WHERE
      f.soft_destroyed_at IS NOT NULL
    GROUP BY
      date
  ) tb5 ON
  tb5.date = d.date
ORDER BY
  d.date;
}
    when :feature_products
      %q{
SELECT
  p.list_no AS  "No.",
  p.name AS "商品名",
  p.maker AS "メーカー",
  p.model AS "型式",
  p.year AS "年式",
  c."name" AS "出品会社",
  a."name" AS "エリア",
  p.min_price AS "最低金額",
  dlt.c AS "詳細アクセス",
  ft.c AS "お気に入り",
  p.bids_count AS "入札数",
  p.same_count AS "同額札",
  b.amount AS "落札金額",
  c2."name" AS "落札会社"
FROM
  products p
LEFT JOIN companies c ON
  c.id = p.company_id
LEFT JOIN areas a ON
  a.id = p.area_id
LEFT JOIN bids b ON
  b.id = p.success_bid_id LEFT JOIN companies c2 ON c2.id = b.company_id
LEFT JOIN (
  SELECT
    dl.product_id,
    count(*) AS c
  FROM
    detail_logs dl
  GROUP BY
    dl.product_id
) dlt ON dlt.product_id = p.id
LEFT JOIN (
  SELECT
    f.product_id,
    count(*) AS c
  FROM
    favorites f
    WHERE soft_destroyed_at IS NULL
  GROUP BY
    f.product_id
) ft ON ft.product_id = p.id
WHERE
  open_id = ?
  AND p.soft_destroyed_at IS NULL
  AND p.featured = TRUE
ORDER BY
  p.list_no;
    }
#     when :area_amount
#       %q{
# SELECT
#   CASE
#     WHEN p2.area_id IS NULL THEN '店頭出品'
#     ELSE a.name
#   END AS "エリア",
#   count(DISTINCT p2.id) AS "出品数",
#   sum(p2.min_price) AS "最低入札価格総額",
#   sum(bc.c) AS "入札数",
#   count(DISTINCT p2.success_bid_id) AS "落札数",
#   ROUND(count(DISTINCT p2.success_bid_id) * 100.0 / count(DISTINCT p2.id) ,2) AS "落札率(%)",
#   sum(b.amount) AS "落札金額"
# FROM
#   products p2
# LEFT JOIN bids b ON
#   b.id = p2.success_bid_id
# LEFT JOIN (
#     SELECT
#       b2.product_id,
#       count(b2.id) AS c
#     FROM
#       bids b2
#     WHERE
#       b2.soft_destroyed_at IS NULL
#     GROUP BY
#       b2.product_id
#   ) bc ON
#   bc.product_id = p2.id
# LEFT JOIN areas a ON
#   a.id = p2.area_id
# WHERE
#   a.soft_destroyed_at IS NULL
#   AND p2.soft_destroyed_at IS NULL
#   AND b.soft_destroyed_at IS NULL
#   AND p2.open_id = ?
# GROUP BY
#   p2.area_id,
#   a.name,
#   a.order_no
# ORDER BY
#   a.order_no;
#     }
#   when :genre_amount
#     %q{
# SELECT
#   xg.name AS 大ジャンル,
#   lg.name AS 中ジャンル,
#   count(p.id) AS 出品商品数,
#   sum(p.min_price) AS "最低入札価格総額(円)",
#   sum(bc1.c) AS 入札数,
#   sum(CASE WHEN p.success_bid_id > 1 THEN 1 ELSE 0 END) AS 落札数,
#   round(sum(CASE WHEN p.success_bid_id > 1 THEN 1 ELSE 0 END) * 100 /  count(DISTINCT p.id), 2) AS "落札率(%)",
#   sum(sb.amount) AS "落札金額合計(円)"
# FROM
#   large_genres lg
# LEFT JOIN xl_genres xg ON
#   xg.id = lg.xl_genre_id
# LEFT JOIN genres g ON
#   g.large_genre_id = lg.id
# LEFT JOIN products p ON
#   p.genre_id = g.id
# LEFT JOIN bids sb ON
#   sb.id = p.success_bid_id
# LEFT JOIN (
#     SELECT
#       b2.product_id,
#       count(b2.id) AS c
#     FROM
#       bids b2
#     WHERE
#       b2.soft_destroyed_at IS NULL
#     GROUP BY
#       b2.product_id
#   ) bc1 ON
#   bc1.product_id = p.id
# WHERE
#   p.soft_destroyed_at IS NULL
#   AND open_id = ?
# GROUP BY
#   lg.name,
#   xg.name,
#   xg.order_no,
#   lg.order_no
# ORDER BY
#   xg.order_no,
#   lg.order_no;
#     }
    end
  end

  def percents(denominators, molecules)
    denominators.to_h do |k, v|
      [k, (((molecules[k] || 0) / v.to_f) * 100).round(2) ]
    end
  end
end
