["No.", "商品名", "メーカー", "型式", "最低入札金額",  "備考欄",
  "入札数", "落札会社", "落札金額", "デメ半", "出品区分", "出品手数料", "組合手数料", "落札会社手数料", "支払金額"].to_csv +
@products.sum do |p|

  arr = [p.list_no, p.name, p.maker, p.model, p.min_price, p.comment]
  if p.success_bid.present?
    arr += [p.bids_count, p.success_company.name, p.success_bid.amount, p.deme_h, p.display,
      "", p.kumiai_fee, p.hanbai_fee, p.shiharai]
  else
    arr += ["", "", "", "", p.display, (p.shuppin_fee > 0 ? p.shuppin_fee : "")]
  end
  arr.to_csv
end
