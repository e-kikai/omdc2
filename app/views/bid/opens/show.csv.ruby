["No.", "大ジャンルID", "大ジャンル", "中ジャンルID", "中ジャンル", "ジャンルID", "ジャンル",
    "商品名", "メーカー", "型式", "年式", "仕様", "現状", "最低入札金額",
    "出品会社", "出品エリア",
    "入札数",  "落札金額", "落札会社No.", "落札会社", "同額札",  "結果", "自社入札", "備考欄", "自社出品", "備考欄"].to_csv +
@products.sum do |p|
  res = [p.list_no, p.xl_genre.id, p.xl_genre.name, p.large_genre.id, p.large_genre.name, p.genre_id, p.genre.name,
    p.name, p.maker, p.model, p.year, p.spec, p.condition, p.min_price,
    p.company.name, p.area_name]
  if p.bid?
    res += [p.bids_count, p.success_bid.amount, p.success_company.no, p.success_company.name]
    # if my_amount = p.bids.where(company: current_company).maximum(:amount)

    # 同額札
    res += [(p.same_count > 1 ? p.same_count : "")]

    # 自社入札結果
    if b = @my_bids.find { |b| b.product_id == p.id }
      res += [(p.success_bid.company.id == current_company.id ? "◯" : "☓")]
    end

    # 自社入札
    if bids = @my_bids.select { |b| b.product_id == p.id }
      bids.each do |b|
        res += [b.amount, b.comment]
      end
    end

    # 自社出品(入札より先に)
    if current_company.id == p.company_id
      res += ['○', p.comment]
    end


  end
  res.to_csv
end
