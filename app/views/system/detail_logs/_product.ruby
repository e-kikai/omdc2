if product.present?
  [
    product.id, product.app_no, product.list_no,
    product.name, product.maker, product.model, (product.hitoyama ? "◯" : ""), product.year, product.min_price,
    product.spec, product.condition, product.comment, product.display,
    product.company_id, product.company&.name,
    product.xl_genre.id, product.xl_genre&.name,
    product.large_genre.id, product.large_genre&.name,
    product.genre_id, product.genre&.name,
    product.created_at,
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
    登録日時
  |
end
