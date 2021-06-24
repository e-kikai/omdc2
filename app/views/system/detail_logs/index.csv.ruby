# %w[ID アクセス日時 IP ホスト名 ユーザID 会社名 ユーザ名
#   リンク元 r リファラ
# ]
# .concat(render("/system/detail_logs/product", product: nil)).to_csv +

header = %w[
  ID アクセス日時 IP ホスト名 ユーザID 会社名 ユーザ名
  リンク元 r リファラ

  商品ID 申込No. No.
  商品名 メーカー 型式 一山 年式 最低入札金額
  仕様 現状 備考欄 出品区分
  出品会社ID 出品会社名
  大ジャンルID 大ジャンル
  中ジャンルID 中ジャンル
  ジャンルID ジャンル名
  出品エリア
  登録日時

  入札数 落札金額	落札会社	同額札
]
#   ].to_csv +

res = header.to_csv
# @detail_logs.sum do |lo|
@detail_logs.find_each(batch_size: 1000)  do |lo|
res += [
    lo.id, lo.created_at, lo.ip, lo.host, lo.user_id, lo.user&.company, lo.user&.name,
    URI.unescape(lo.link_source), lo.r, URI.unescape(lo.referer).scrub('♪'),
  # ].concat(render("/system/detail_logs/product", product: lo&.product)).to_csv
    lo&.product.id, lo&.product.app_no, lo&.product.list_no,
    lo&.product.name, lo&.product.maker, lo&.product.model, (lo&.product.hitoyama ? "◯" : ""), lo&.product.year, lo&.product.min_price,
    lo&.product.spec, lo&.product.condition, lo&.product.comment, lo&.product.display,
    lo&.product.company_id, lo&.product.company&.name,
    lo&.product.xl_genre.id, lo&.product.xl_genre&.name,
    lo&.product.large_genre.id, lo&.product.large_genre&.name,
    lo&.product.genre_id, lo&.product.genre&.name,
    lo&.product.area_name,
    lo&.product.created_at,

    (lo&.product.bids_count if lo&.product.success_bid.present?),
    lo&.product.success_bid&.amount,
    lo&.product.success_company&.name_remove_kabu,
    (lo&.product.same_count if lo&.product.same_count > 1)
  ].to_csv
end

# columns = %w|
#   detail_logs.id  detail_logs.created_at detail_logs.ip detail_logs.host detail_logs.user_id
#   users.company users.name 1 detail_logs.r detail_logs.referer
#   products.id products.app_no products.list_no products.name products.maker products.model
#   products.hitoyama products.year products.min_price products.spec products.condition products.comment products.display
#   products.company_id companies.name
#   xl_genres.id xl_genres.name
#   large_genres.id large_genres.name
#   genres.id genres.name
#   areas.name products.created_at

#   products.bids_count
#   success_bids_products_join.amount
#   success_companies_products.name
#   products.same_count
# |
# @detail_logs.pluck(columns).each do |lo|
#   ### 整形 ###
#   hitoyama_idx = columns.find_index("products.hitoyama")
#   name_idx     = columns.find_index("products.name")
#   lo[hitoyama_idx] = if lo[hitoyama_idx] == true
#     "○"
#   elsif lo[name_idx] =~ /一山|1山|雑品/
#     "□"
#   else
#     "×"
#   end

#   r_idx   = columns.find_index("detail_logs.r")
#   ref_idx = columns.find_index("detail_logs.referer")

#   ls = DetailLog.link_source_base(lo[r_idx], lo[ref_idx])
#   lo[columns.find_index("1")]   = URI.unescape(ls).scrub('♪')
#   lo[ref_idx] = URI.unescape(lo[ref_idx]).scrub('♪')

#   res += lo.to_csv
# end

res