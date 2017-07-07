["申込No.", "No.", "商品名", "メーカー", "型式", "一山", "年式", "最低入札金額",
  "大ジャンルID", "大ジャンル", "中ジャンルID", "中ジャンル", "ジャンルID", "ジャンル",
  "仕様", "現状", "備考欄", "出品区分", "登録日時"].to_csv +
@products.sum do |p|
  [p.app_no, p.list_no, p.name, p.maker, p.model, (p.hitoyama ? "◯" : ""), p.year, p.min_price,
    p.xl_genre.id, p.xl_genre.name, p.large_genre.id, p.large_genre.name, p.genre_id, p.genre.name,
    p.spec, p.condition, p.comment, p.display, p.created_at].to_csv
end
