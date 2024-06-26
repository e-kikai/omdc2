[
  "ID", "URL",
  "ページタイトル",
  "リストNo.", "商品名", "メーカー", "型式", "年式", "最低入札金額", "出品エリア"
].to_csv +
@products.sum do |pr|
  [
    pr.id, "#{root_url}products/#{pr.id}",
    "#{pr.name.strip} #{pr.maker.strip} #{pr.model.strip} ｜ 機械団地 #{@open_now.name}",
    pr.list_no, pr.name.strip, pr.maker.strip, pr.model.strip, pr.year.strip, pr.min_price, pr.area_name
  ].to_csv
end.to_s
