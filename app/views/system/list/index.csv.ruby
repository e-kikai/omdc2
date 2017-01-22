["リストNo.", "会社No.", "会社名", "申込No.", "商品名", "メーカー", "型式", "年式", "最低入札金額", "出品エリア"].to_csv +
@products.sum do |p|
  [p.list_no, p.company.no, p.company.name, p.app_no, p.name, p.maker, p.model, p.year, p.min_price, p.area_name].to_csv
end
