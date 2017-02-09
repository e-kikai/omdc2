["登録No.", "リストNo.", "商品名", "メーカー", "型式", "一山", "年式", "最低入札金額", "備考欄", "出品区分", "登録日時"].to_csv +
@products.sum do |p|
  [p.app_no, p.list_no, p.name, p.maker, p.model, (p.hitoyama ? "◯" : ""), p.year, p.min_price, p.comment, p.display, p.created_at].to_csv
end
