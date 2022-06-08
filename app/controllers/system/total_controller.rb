class System::TotalController < System::ApplicationController
  include Exports

  def index
    @open_selector  = Open.order(bid_end_at: :desc).pluck(:name, :id)
    @total_selector = {
      "検索方法/詳細アクセス、一山"    => :search_hitoyama_by_period,
      "リンク元/詳細アクセス、一山"    => :links_hitoyama_by_period,
      "出品会社/デメ半手数料"          => :company_deme,
      "価格帯/落札結果金額"            => :price_amount,
      "日別/アクセス,お気に入り利用"   => :date_favorite,
      "入札会/アクセス,お気に入り利用" => :opens_favorite,
    }

    @open_id = params[:open_id] || @open_now&.id || (@open_next&.id  ? (@open_next&.id - 1) : @open_selector.first[1])
    @total   = params[:total] || @total_selector.first[1]
    @title   = "#{@open_selector.to_h.key(@open_id.to_i)} - #{@total_selector.key(@total.to_sym)}"

    target = if @total =~ /by_period/
      open = Open.find(@open_id)
      [make_sql(@total), open.bid_start_at.beginning_of_day, open.bid_end_at.end_of_day]
    else
      [make_sql(@total), @open_id]
    end

    sanitize_sql = ActiveRecord::Base.send(:sanitize_sql_array, target)
    @result      = ActiveRecord::Base.connection.select_all(sanitize_sql)

    respond_to do |format|
      format.html
      format.csv { export_csv "#{@total}_#{@open_id}.csv" }
    end
  end

  def goal
    sql = %q{
    SELECT
    o.id AS ID,
    o.name AS "入札会名",
    tp.s_min_price AS "出品最低入札価格(円)",
    tp.c_id AS "出品数",
    tb.s_amount AS "落札金額(円)",
    tp.c_success_bid_id AS "落札数",
    tb.c_id AS "入札数",
    ROUND(tp.c_success_bid_id * 100.0 / tp.c_id, 2) AS "落札割合(%)",
    tp.c_hitoyama AS "一山出品数",
    ROUND(tp.c_hitoyama * 100.0 / tp.c_id, 2) AS "一山出品割合(%)",
    tdl.c_utag AS "utag数",
    tdl.c_id AS "詳細閲覧",
    tdl.c_hitoyama AS "一山閲覧",
    ROUND(tdl.c_hitoyama * 100.0 / tdl.c_id, 2) AS "一山閲覧割合(%)"
  FROM
    opens o
  LEFT JOIN (
      SELECT
        p.open_id,
        count(DISTINCT p.id) AS c_id,
        sum(p.min_price) AS s_min_price,
        count(DISTINCT p.success_bid_id) AS c_success_bid_id,
        sum(CASE WHEN p.hitoyama = 'true' OR p.name ~ '(一山|1山|雑品)' THEN 1 END) AS c_hitoyama
      FROM
        products p
      WHERE
        p.soft_destroyed_at IS NULL
      GROUP BY
        p.open_id
    ) tp ON
    tp.open_id = o.id
  LEFT JOIN (
      SELECT
        p2.open_id,
        count(b.id) AS c_id,
        sum(CASE WHEN b.id = p2.success_bid_id THEN b.amount END) AS s_amount
      FROM
        products p2
      LEFT JOIN bids b ON
        b.product_id = p2.id
      WHERE
        p2.soft_destroyed_at IS NULL
        AND b.soft_destroyed_at IS NULL
      GROUP BY
        p2.open_id
    ) tb ON tb.open_id = o.id
    LEFT JOIN (
      SELECT
        p3.open_id,
        count(dl.id) AS c_id,
        count(DISTINCT dl.utag) as c_utag,
        count(CASE WHEN p3.hitoyama = 'true' OR p3.name ~ '(一山|1山|雑品)'  AND dl.id IS NOT NULL THEN 1 END) AS c_hitoyama
      FROM
        detail_logs dl
      LEFT JOIN products p3 ON
        dl.product_id = p3.id
      WHERE
        p3.soft_destroyed_at IS NULL
      GROUP BY
        p3.open_id
    ) tdl ON tdl.open_id = o.id
  WHERE
    o.soft_destroyed_at IS NULL
  ORDER BY
    o.id
}

    @result = ActiveRecord::Base.connection.select_all(sql)

    respond_to do |format|
      format.html
      format.csv { export_csv "goal.csv", :index }
    end
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
    when :opens_favorite
    %q{
SELECT
  o.id,
  regexp_replace(o.name, '第([0-9]+)回(.*)', '第\1回') as "入札会",
  tb6.user_c AS "ユーザ(累計)",
  COALESCE(tb6.user_c - LAG(tb6.user_c, 1) OVER (
  ORDER BY
    o.id
  ), tb6.user_c) AS "ユーザ(新規)",
  tb8.pc AS "出品数",
  tb7.detail_c AS "詳細(件)",
  tb7.detail_utag AS "詳細(utag)",
  tb7.detail_u AS "詳細(ログイン人)",
  tb7.detail_p AS "詳細(商品数)",
  tb1.fa_c AS "お気に入り(件)",
  tb1.fa_u AS "お気に入り(人)",
  tb1.fa_p AS "お気に入り(商品)",
  tb3.delete_c AS "削除(件)",
  tb3.delete_u AS "削除(人)",
  tb2.pdf_c AS "PDF生成(件)",
  tb2.pdf_u AS "PDF生成(人)",
  tb2.pdf_p AS "PDF生成(商品)"
  -- tb4.pdf_delete_c AS "PDF&削除(件)",
  -- tb4.pdf_delete_u AS "PDF&削除(人)"
  -- tb5.pdf_miss_c AS "短時間で削除(件)",
  -- tb5.pdf_miss_u AS "短時間で削除(人)"
FROM
  opens o
LEFT JOIN (
    SELECT
      p2.open_id,
      count(f2.id) AS fa_c,
      count(DISTINCT f2.user_id) AS fa_u,
      count(DISTINCT f2.product_id) AS fa_p
    FROM
      favorites f2
    LEFT JOIN products p2 ON
      p2.id = f2.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
    GROUP BY
      p2.open_id
  ) tb1 ON
  tb1.open_id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(f2.id) AS pdf_c,
      count(DISTINCT f2.user_id) AS pdf_u,
      count(DISTINCT f2.product_id) AS pdf_p
    FROM
      favorites f2
    LEFT JOIN products p2 ON
      p2.id = f2.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
      AND f2.amount IS NOT NULL
    GROUP BY
      p2.open_id
  ) tb2 ON
  tb2.open_id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(f2.id) AS delete_c,
      count(DISTINCT f2.user_id) AS delete_u
    FROM
      favorites f2
    LEFT JOIN products p2 ON
      p2.id = f2.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
      AND f2.soft_destroyed_at IS NOT NULL
    GROUP BY
      p2.open_id
  ) tb3 ON
  tb3.open_id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(f2.id) AS pdf_delete_c,
      count(DISTINCT f2.user_id) AS pdf_delete_u
    FROM
      favorites f2
    LEFT JOIN products p2 ON
      p2.id = f2.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
      AND f2.amount IS NOT NULL
      AND f2.soft_destroyed_at IS NOT NULL
    GROUP BY
      p2.open_id
  ) tb4 ON
  tb4.open_id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(f2.id) AS pdf_miss_c,
      count(DISTINCT f2.user_id) AS pdf_miss_u
    FROM
      favorites f2
    LEFT JOIN products p2 ON
      p2.id = f2.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
      AND f2.soft_destroyed_at IS NOT NULL
      AND f2.soft_destroyed_at < f2.created_at + INTERVAL '1hour'
    GROUP BY
      p2.open_id
  ) tb5 ON
  tb5.open_id = o.id
LEFT JOIN (
    SELECT
      o2.id,
      count(u.id) AS user_c
    FROM
      opens o2
    LEFT JOIN users u ON
      u.created_at < o2.bid_end_at
    WHERE
      u.confirmed_at IS NOT NULL
    GROUP BY
      o2.id
  )
  tb6 ON
  tb6.id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(dl.id) AS detail_c,
      count(DISTINCT dl.utag) AS detail_utag,
      count(DISTINCT dl.user_id) AS detail_u,
      count(DISTINCT dl.product_id) AS detail_p
    FROM
      detail_logs dl
    LEFT JOIN products p2 ON
      p2.id = dl.product_id
    WHERE
      p2.soft_destroyed_at IS NULL
    GROUP BY
      p2.open_id
  ) tb7 ON
  tb7.open_id = o.id
LEFT JOIN (
    SELECT
      p2.open_id,
      count(p2.id) AS pc
    FROM
      products p2
    WHERE
      p2.soft_destroyed_at IS NULL
    GROUP BY
      p2.open_id
  ) tb8 ON
  tb8.open_id = o.id
WHERE
  o.id > 61
ORDER BY
  o.id
    }
    end
  end
end
