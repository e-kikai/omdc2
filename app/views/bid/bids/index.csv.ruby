["リストNo.", "商品名", "メーカー", "型式", "最低入札金額", "入札金額",  "備考欄", "入札日時"].to_csv +
@bids.sum do |b|
  [b.product.list_no, b.product.name, b.product.maker, b.product.model, b.product.min_price, b.amount, b.comment, b.created_at].to_csv
end
