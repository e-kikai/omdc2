res = %w(
  No.
  会社名
  落札代金請求額
  デメ半
  小計
  貴社受取手数料
  差引
  消費税
  差引落札請求額
  出品支払額
  デメ半
  小計
  組合手数料
  販売手数料
  出品手数料
  差引
  消費税
  差引出品支払額
  結果
  落札請求額
  出品支払額
).to_csv

@companies.each do |c|
  next if @company_products[c.id][:products].blank? && @company_products[c.id][:success_products].blank?

  total = (@open_now.tax_total(@company_products[c.id][:products].sum(&:shiharai)) - @open_now.tax_total(@company_products[c.id][:success_products].sum(&:seikyu))).abs
  res << ([
    c.no,
    c.name,
    (@company_products[c.id][:success_products].sum(&:success_price)),
    (@company_products[c.id][:success_products].sum(&:deme_h)),
    (@company_products[c.id][:success_products].sum(&:success_price) - @company_products[c.id][:success_products].sum(&:deme_h)),
    (@company_products[c.id][:success_products].sum(&:hanbai_fee)),
    (@company_products[c.id][:success_products].sum(&:seikyu)),
    (@open_now.tax_calc(@company_products[c.id][:success_products].sum(&:seikyu))),
    (@open_now.tax_total(@company_products[c.id][:success_products].sum(&:seikyu))),

    (@company_products[c.id][:products].sum(&:success_price)),
    (@company_products[c.id][:products].sum(&:deme_h)),
    (@company_products[c.id][:products].sum(&:success_price) - @company_products[c.id][:products].sum(&:deme_h)),
    (@company_products[c.id][:products].sum(&:kumiai_fee)),
    (@company_products[c.id][:products].sum(&:hanbai_fee)),
    (@company_products[c.id][:products].sum(&:shuppin_fee)),
    (@company_products[c.id][:products].sum(&:shiharai)),
    (@open_now.tax_calc(@company_products[c.id][:products].sum(&:shiharai))),
    (@open_now.tax_total(@company_products[c.id][:products].sum(&:shiharai))),
  ] + (
    @company_products[c.id][:products].sum(&:shiharai) > @company_products[c.id][:success_products].sum(&:seikyu) ? ["支払", "", total] : ["請求", total, ""]
  )).to_csv
end

res
