["No.", "大ジャンルID", "大ジャンル", "中ジャンルID", "中ジャンル", "ジャンルID", "ジャンル",
   "商品名", "メーカー", "型式", "最低入札金額", "入札数",  "落札金額", "落札会社No.", "落札会社"].to_csv +
@products.sum do |p|
  res = [p.list_no, p.xl_genre.id, p.xl_genre.name, p.large_genre.id, p.large_genre.name, p.genre_id, p.genre.name,
    p.name, p.maker, p.model, p.min_price]
  res += if p.bid?
    [p.bids_count, p.success_bid.amount, p.success_company.no, p.success_company.name]
  else
    []
  end
  res.to_csv
end
