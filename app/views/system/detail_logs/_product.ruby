if product.present?
  [
    product.id, product.app_no, product.list_no,
    product.name, product.maker, product.model, (product.hitoyama ? "◯" : ""), product.year, product.min_price,
    product.spec, product.condition, product.comment, product.display,
    product.company_id, product.company&.name,
    product.xl_genre.id, product.xl_genre&.name,
    product.large_genre.id, product.large_genre&.name,
    product.genre_id, product.genre&.name,
    product.area_name,
    product.created_at,

    (product.bids_count if product.success_bid.present?),
    product.success_bid&.amount,
    product.success_company&.name_remove_kabu,
    (product.same_count if product.same_count > 1)
  ]
else
  %w|
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
  |
end
