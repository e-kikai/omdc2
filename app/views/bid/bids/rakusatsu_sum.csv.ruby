["No.", "商品名", "メーカー", "型式", "最低入札金額", "入札金額",  "備考欄", "入札日時",
   "落札金額", "結果", "デメ半", "落札会社手数料", "請求金額"].to_csv +
@bids.sum do |b|
  [b.product.list_no, b.product.name, b.product.maker, b.product.model, b.product.min_price, b.amount, b.comment, b.created_at,
     b&.product&.success_price, (b.success? ? "◯" : "×"), b.product.deme_h, b.product.hanbai_fee, b.product.seikyu].to_csv
end
