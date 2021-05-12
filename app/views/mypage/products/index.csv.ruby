['No.', '商品名', 'メーカー', '型式', '年式', '最低入札金額', '展示場所'].to_csv +
@products.sum do |p|
  [p.list_no, p.name.strip, p.maker.strip, p.model.strip, p.year.strip, p.min_price, p.area_name.strip].to_csv
end
