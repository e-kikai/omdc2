["登録No.", "商品名", "メーカー", "型式", "一山", "最低入札金額", "年式", "仕様", "現状", "備考欄", "出品区分", "youtube", "削除"].to_csv +
@products.sum do |p|
  [p.app_no, p.name, p.maker, p.model, (p.hitoyama ? "◯" : ""), p.min_price, p.year, p.spec, p.condition, p.comment, p.display, p.youtube].to_csv
end
