[
  "ID", "URL",
  "ページタイトル",
  "リストNo.", "商品名", "メーカー", "型式", "年式", "最低入札金額", "出品エリア"
].to_csv +
@products.sum do |pr|
  [
    pr.id, url_for("/products/#{pr.id}", only_path: false),
    "#{pr.name.strip} #{pr.maker.strip} #{pr.model.strip} 商品詳細",
    pr.list_no, pr.name.strip, pr.maker.strip, pr.model.strip, pr.year.strip, pr.min_price, pr.area_name
  ].to_csv
end.to_s
