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
@detail_logs.find_each(batch_size: 500)  do |lo|
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

  # GC.start
end

res