prawn_document do |pdf|
  @companies.each do |c|
    next if @company_products[c.id][:products].blank? && @company_products[c.id][:success_products].blank?

    pdf.start_new_page layout: :portrait
    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "#{c.name} 領収書"

  #   if @company_products[c.id][:success_products].present?
  #     pdf.start_new_page layout: :landscape
  #     pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
  #
  #     pdf.text "#{c.name} 落札個別計算書"
  #
  #     arr = [%w|No. 商品名 最低入札金額 落札金額 デメ半 落札会社手数料 % 請求金額 備考欄|] +
  #     @company_products[c.id][:success_products].map do |p|
  #       [p.list_no, p.name, number_with_delimiter(p.min_price), number_with_delimiter(p.success_bid.amount), number_with_delimiter(p.deme_h), number_with_delimiter(p.hanbai_fee), number_with_delimiter(p.hanbai_fee_per), number_with_delimiter(p.seikyu), ""]
  #     end + [
  #       [ {content: "", colspan: 4}, "落札数 : #{@company_products[c.id][:success_products].length}", {content: "合計金額", colspan: 2}, number_with_delimiter(@company_products[c.id][:success_products].sum(&:seikyu))],
  #       [ {content: "", colspan: 5}, {content: "消費税 : #{@open_now.tax}%", colspan: 2}, number_with_delimiter(@open_now.tax_calc(@company_products[c.id][:success_products].sum(&:seikyu)))],
  #       [ {content: "", colspan: 5}, {content: "差引落札請求額", colspan: 2}, number_with_delimiter(@open_now.tax_total(@company_products[c.id][:success_products].sum(&:seikyu)))],
  #     ]
  #
  #     pdf.table arr, {
  #       header: true,
  #     } do |t|
  #       t.cells.style(size: 10)
  #
  #       t.columns(0).style(width: 50,  align: :right)
  #       t.columns(1).style(width: 120, align: :left)
  #       t.columns(2).style(width: 80, align: :right)
  #       t.columns(3).style(width: 80, align: :right)
  #       t.columns(4).style(width: 80, align: :right)
  #       t.columns(5).style(width: 80, align: :right)
  #       t.columns(6).style(width: 24, align: :right)
  #       t.columns(7).style(width: 80, align: :right)
  #       t.columns(8).style(width: 160, align: :left)
  #
  #       t.row(0).style(align: :left)
  #
  #       t.row(-1).columns(0).border_width = 0
  #       t.row(-2).columns(0).border_width = 0
  #       t.row(-3).columns(0).border_width = 0
  #     end
  #   end
  #
  #   if @company_products[c.id][:products].present?
  #     pdf.start_new_page layout: :landscape
  #     pdf.text "#{c.name} 出品個別計算書"
  #
  #     arr = [%w|No. 商品名 最低入札金額 落札金額 落札会社 デメ半 出品区分 出品手数料 % 組合手数料 % 落札会社手数料 % 支払金額 備考欄|] +
  #     @company_products[c.id][:products].map do |p|
  #       [p.list_no, p.name, number_with_delimiter(p.min_price),
  #         number_with_delimiter(p.success_price), p.success_company.try(:name_remove_kabu), number_with_delimiter(p.deme_h),
  #         p.display, number_with_delimiter(p.shuppin_fee), number_with_delimiter(p.shuppin_fee_per),
  #         number_with_delimiter(p.kumiai_fee), number_with_delimiter(p.kumiai_fee_per), number_with_delimiter(p.hanbai_fee),
  #         number_with_delimiter(p.hanbai_fee_per), number_with_delimiter(p.seikyu), ""]
  #     end + [
  #       [ {content: "", colspan: 9}, {content: "出品数 : #{@company_products[c.id][:products].length}", colspan: 2}, {content: "合計金額", colspan: 2}, number_with_delimiter(@company_products[c.id][:products].sum(&:shiharai))],
  #       [ {content: "", colspan: 11}, {content: "消費税 : #{@open_now.tax}%", colspan: 2}, number_with_delimiter(@open_now.tax_calc(@company_products[c.id][:products].sum(&:shiharai)))],
  #       [ {content: "", colspan: 11}, {content: "差引出品支払額", colspan: 2}, number_with_delimiter(@open_now.tax_total(@company_products[c.id][:products].sum(&:shiharai)))],
  #     ]
  #
  #     pdf.table arr, {
  #       header: true,
  #     } do |t|
  #       t.cells.style(size: 9)
  #
  #       t.columns(0).style(width: 35,  align: :right)
  #       t.columns(1).style(width: 80, align: :left)
  #       t.columns(2).style(width: 60, align: :right)
  #       t.columns(3).style(width: 60, align: :right)
  #       t.columns(4).style(width: 60, align: :left)
  #       t.columns(5).style(width: 60, align: :right)
  #
  #       t.columns(6).style(width: 50, align: :left)
  #       t.columns(7).style(width: 60, align: :right)
  #       t.columns(8).style(width: 25, align: :right)
  #       t.columns(9).style(width: 60, align: :right)
  #       t.columns(10).style(width: 25, align: :right)
  #       t.columns(11).style(width: 60, align: :right)
  #       t.columns(12).style(width: 25, align: :right)
  #       t.columns(13).style(width: 60, align: :right)
  #       t.columns(14).style(width: 48, align: :left)
  #
  #       t.row(0).style(align: :left)
  #
  #       t.row(0).columns([2, 11]).style(size: 7)
  #
  #       t.row(-1).columns(0).border_width = 0
  #       t.row(-2).columns(0).border_width = 0
  #       t.row(-3).columns(0).border_width = 0
  #     end
  #   end
  #
  # end
  #
  # @companies.each do |c|
  #   next if @company_products[c.id][:products].blank? && @company_products[c.id][:success_products].blank?
  #   sashihiki = @company_products[c.id][:success_products].sum(&:seikyu) - @company_products[c.id][:products].sum(&:shiharai)
  #   next if sashihiki <= 0
  #
  #
  #   pdf.start_new_page layout: :portrait, margin: [8.mm]
  #   pdf.font "vendor/assets/fonts/ipaexm.ttf"
  #
  #   [0, 148.mm].each do |side|
  #     pdf.bounding_box([0, side + (132.5).mm], width: 194.mm, height: (132.5).mm) do
  #       pdf.stroke_bounds
  #
  #       pdf.text_box "#{c.name} 御中", {size: 16, at: [12.mm, (132.5- 16).mm]}
  #       pdf.stroke_line [12.mm, (132.5- 23).mm], [70.mm, (132.5- 23).mm]
  #       pdf.text_box (side == 0 ? "領収証(控)" : "領収証"), {size: 26, at: [0, (132.5- 27).mm], align: :center}
  #       pdf.text_box "下記の通り、御社の#{@open_now.name}の清算金額を領収いたしました。", {size: 12, at: [8.mm, (132.5- 38).mm]}
  #       pdf.text_box "記", {size: 12, at: [8.mm, (132.5- 52).mm], align: :center}
  #
  #       pdf.bounding_box([8.mm, 212], width: 178.mm, height: 42.mm) do
  #         arr = [
  #           %w|請求金額(税抜) 消費税 合計請求金額|,
  #           [number_to_currency(sashihiki), number_to_currency(@open_now.tax_calc(sashihiki)), number_to_currency(@open_now.tax_total(sashihiki))]
  #         ]
  #         pdf.table arr do |t|
  #           t.cells.style(size: 15)
  #
  #           t.row(0).style(size: 12, align: :center, valign: :middle)
  #           t.row(1).style(size: 16, height: 13.mm, align: :right, valign: :center)
  #
  #           t.columns(0).style(width: 65.mm)
  #           t.columns(1).style(width: 43.mm)
  #           t.columns(2).style(width: 70.mm)
  #         end
  #       end
  #
  #       pdf.bounding_box([8.mm, 50.mm], width: 56.mm, height: 42.mm) do
  #         arr = [ [{content: "内訳", rowspan: 2}, "", "現金"], ["", "小切手"] ]
  #         pdf.table arr do |t|
  #           t.cells.style(size: 12, align: :center)
  #
  #           t.row([0, 1]).style(height: 8.mm)
  #
  #           t.columns(0).style(width: 17.mm, valign: :center)
  #           t.columns(1).style(width: 8.mm)
  #           t.columns(2).style(width: 26.mm)
  #         end
  #       end
  #
  #       pdf.bounding_box([8.mm, 50.mm], width: 178.mm, height: 42.mm) do
  #         # pdf.stroke_bounds
  #
  #         pdf.default_leading 8
  #
  #         pdf.text "以上", size: 12, align: :right
  #         pdf.text "平成　　年　　月　　日", size: 12, align: :right
  #         pdf.text "大阪機械卸業団地協同組合", size: 14, align: :right
  #         pdf.text "〒573-0965 東大阪市本庄西2-5-10", size: 12, align: :right
  #         pdf.text "TEL 06-6747-7521　FAX 06-6747-7525", size: 12, align: :right
  #       end
  #     end
  #   end
  end

end
