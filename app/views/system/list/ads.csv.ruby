[
  "ID", "URL",
  "ページタイトル",
  "リストNo.", "商品名", "メーカー", "型式", "年式", "最低入札金額", "出品エリア"
].to_csv +
@products.sum do |pr|
  [
    pr.id, "#{url_for(only_path: false)}products/#{pr.id}",
    "#{pr.name.strip} #{pr.maker.strip} #{pr.model.strip} ｜ 機械団地 #{site}",
    pr.list_no, pr.name.strip, pr.maker.strip, pr.model.strip, pr.year.strip, pr.min_price, pr.area_name
  ].to_csv
end.to_s
