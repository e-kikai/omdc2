["No.", "商品名", "メーカー", "型式", "最低入札金額", "内容",  "出品場所"].to_csv +
@products.sum do |p|
  [p.list_no, p.name, p.maker, p.model, p.min_price, (p.success_company.blank? ? "元引き" : "引取"), p.area_name].to_csv
end