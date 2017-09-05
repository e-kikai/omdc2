prawn_document do |pdf|
  @companies.each do |c|
    success_products = @company_products[c.id][:success_products] # 落札一覧
    products         = @company_products[c.id][:products]         # 出品一覧

    next if products.blank? && success_products.blank?

    pdf.start_new_page layout: :portrait, margin: [10.mm, 24.mm]
    pdf.font "vendor/assets/fonts/ipaexm.ttf"

    pdf.default_leading 2

    # pdf.stroke_axis

    pdf.text "#{c.zip} #{c.address}", size: 12
    pdf.text "#{c.name} 御中", size: 20
    pdf.stroke_line [0, 263.mm], [90.mm, 263.mm]

    pdf.text " ", size: 5

    # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "#{c.no}", size: 12, leading: 16
    pdf.text " ", size: 10

    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    pdf.text "#{@open_now.name}", size: 16

    pdf.bounding_box([96.mm, 276.mm], width: 76.mm, height: 120.mm) do
      # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "平成#{Time.now.strftime("%Y").to_i - 1988}年#{Time.now.strftime("%m月%d日")}", size: 12, align: :center
      pdf.text " ", size: 12
      pdf.text @open_now.owner, size: 14, align: :center
    end

    pdf.bounding_box([0, 224.mm], width: 76.mm, height: 100.mm) do
      # pdf.stroke_bounds

      pdf.text "落札代金請求書", size: 14, align: :center

      arr1 = [
        ["落札代金請求額(イ)", number_with_delimiter(success_products.sum(&:success_price))],
        ["デメ半(ロ)", number_with_delimiter(success_products.sum(&:deme_h))],
        ["小計(イ)-(ロ)=(ハ)", number_with_delimiter(success_products.sum(&:success_price) - success_products.sum(&:deme_h))],
        ["貴社受取手数料(ニ)", number_with_delimiter(success_products.sum(&:hanbai_fee))],
        ["差引(ハ)-(ニ)", number_with_delimiter(success_products.sum(&:seikyu))],
        ["消費税 : #{@open_now.tax}%", number_with_delimiter(@open_now.tax_calc(success_products.sum(&:seikyu)))],
        ["差引落札請求額", number_with_delimiter(@open_now.tax_total(success_products.sum(&:seikyu)))],
      ]

      pdf.table arr1, {
        header: false,
      } do |t|
        t.columns(0).style(width: 46.mm, align: :left, padding: 4)
        t.columns(1).style(width: 30.mm, align: :right, padding: 4)
      end

    end

    pdf.bounding_box([88.mm, 224.mm], width: 76.mm, height: 120.mm) do
      # pdf.stroke_bounds

      pdf.text "出品支払書", size: 14, align: :center

      arr1 = [
        ["出品支払額(イ)", number_with_delimiter(products.sum(&:success_price))],
        ["デメ半(ロ)", number_with_delimiter(products.sum(&:deme_h))],
        ["小計(イ)-(ロ)=(ハ)", number_with_delimiter(products.sum(&:success_price) - products.sum(&:deme_h))],
        ["出品料(ニ)組合手数料", number_with_delimiter(products.sum(&:kumiai_fee))],
        ["出品料(ニ)販売手数料", number_with_delimiter(products.sum(&:hanbai_fee))],
        ["出品料(ニ)出品手数料", number_with_delimiter(products.sum(&:shuppin_fee))],

        ["差引(ハ)-(ニ)", number_with_delimiter(products.sum(&:shiharai))],
        ["消費税 : #{@open_now.tax}%", number_with_delimiter(@open_now.tax_calc(products.sum(&:shiharai)))],
        ["差引出品支払額", number_with_delimiter(@open_now.tax_total(products.sum(&:shiharai)))],

        ["落札請求額", number_with_delimiter(@open_now.tax_total(success_products.sum(&:seikyu)))],
        ["出品支払額", number_with_delimiter(@open_now.tax_total(products.sum(&:shiharai)))],
        [
          (products.sum(&:shiharai) >= success_products.sum(&:seikyu) ? "差引出品支払額" : "差引落札請求額"),
          number_with_delimiter((@open_now.tax_total(products.sum(&:shiharai)) - @open_now.tax_total(success_products.sum(&:seikyu))).abs)
        ],
        ["", ""]
      ]

      pdf.table arr1, {
        header: false,
      } do |t|
        t.columns(0).style(width: 46.mm, align: :left, padding: 4)
        t.columns(1).style(width: 30.mm, align: :right, padding: 4)

        t.row(-4).style(size: 14, border_width: 0, padding: 2, padding_top: 18)
        t.row(-3).style(size: 14, border_width: 0, padding: 2, padding_bottom: 18)
        t.row(-2).style(size: 16, border_width: 0, border_top_width: 1, border_bottom_width: 1, padding: 2)
        t.row(-1).style(size: 14, border_width: 0, border_bottom_width: 1, padding: 0, height: 3)

      end
    end

    pdf.bounding_box([0, 92.mm], width: 178.mm, height: 80.mm) do
      # pdf.stroke_bounds

      pdf.default_leading 6

      if products.sum(&:shiharai) >= success_products.sum(&:seikyu)
        pdf.text "お支払い額は上記の通りです。", size: 12
        pdf.text "平成#{@open_now.payment_date.strftime("%Y").to_i - 1988}年#{@open_now.payment_date.strftime("%m月%d日")}にお支払い致します。", size: 16

      else
        pdf.text "御請求額は上記の通りです。", size: 12
        pdf.text "平成#{@open_now.billing_date.strftime("%Y").to_i - 1988}年#{@open_now.billing_date.strftime("%m月%d日")}までにご入金下さい。", size: 16
        pdf.text ""
        # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
        pdf.text "商工中金東大阪支店", size: 12

        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        pdf.text "当座預金 2016354", size: 12
        pdf.text "口座名称 大阪機械卸業団地協同組合共同展示場  ", size: 12
        pdf.text "略称 キカイダンチテンジジョウ", size: 12

        # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
        pdf.text "お願い:お振り込みいただく場合は、振込手数料は貴社でご負担下さい。", size: 12
      end
    end

    pdf.bounding_box([0, 34.mm], width: 178.mm, height: 20.mm) do
      pdf.text "註:落札請求額と出品支払額の双方がある場合、相殺し差額決済とします。", size: 12
    end

    ### 落札個別計算書 ###
    if @company_products[c.id][:success_products].present?
      pdf.start_new_page layout: :landscape, margin: 8.mm
      pdf.default_leading 2
      pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"

      pdf.text "#{c.name} 落札個別計算書"

      arr = [%w|No. 商品名 最低入札金額 落札金額 デメ半 落札会社手数料 % 請求金額 備考欄|] +
      @company_products[c.id][:success_products].map do |p|
        [p.list_no, p.name, number_with_delimiter(p.min_price), number_with_delimiter(p.success_bid.amount), number_with_delimiter(p.deme_h), number_with_delimiter(p.hanbai_fee), number_with_delimiter(p.hanbai_fee_per), number_with_delimiter(p.seikyu), ""]
      end + [
        [ {content: "", colspan: 4}, "落札数 : #{@company_products[c.id][:success_products].length}", {content: "合計金額", colspan: 2}, number_with_delimiter(@company_products[c.id][:success_products].sum(&:seikyu))],
        [ {content: "", colspan: 5}, {content: "消費税 : #{@open_now.tax}%", colspan: 2}, number_with_delimiter(@open_now.tax_calc(@company_products[c.id][:success_products].sum(&:seikyu)))],
        [ {content: "", colspan: 5}, {content: "差引落札請求額", colspan: 2}, number_with_delimiter(@open_now.tax_total(@company_products[c.id][:success_products].sum(&:seikyu)))],
      ]

      pdf.table arr, {
        header: true,
      } do |t|
        t.cells.style(size: 10)

        t.columns(0).style(width: 50,  align: :right)
        t.columns(1).style(width: 140, align: :left)
        t.columns(2).style(width: 80, align: :right)
        t.columns(3).style(width: 80, align: :right)
        t.columns(4).style(width: 80, align: :right)
        t.columns(5).style(width: 80, align: :right)
        t.columns(6).style(width: 24, align: :right)
        t.columns(7).style(width: 80, align: :right)
        t.columns(8).style(width: 160, align: :left)

        t.row(0).style(align: :left)

        t.row(-1).columns(0).border_width = 0
        t.row(-2).columns(0).border_width = 0
        t.row(-3).columns(0).border_width = 0
      end
    end

    ### 出品個別計算書 ###
    if @company_products[c.id][:products].present?
      pdf.start_new_page layout: :landscape, margin: 8.mm
      pdf.default_leading 2
      pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "#{c.name} 出品個別計算書"

      arr = [%w|No. 商品名 最低入札金額 落札金額 落札会社 デメ半 出品区分 出品手数料 % 組合手数料 % 落札会社手数料 % 支払金額 備考欄|] +
      @company_products[c.id][:products].map do |p|
        [p.list_no, p.name, number_with_delimiter(p.min_price),
          number_with_delimiter(p.success_price), p.success_company.try(:name_remove_kabu), number_with_delimiter(p.deme_h),
          p.display, number_with_delimiter(p.shuppin_fee), number_with_delimiter(p.shuppin_fee_per),
          number_with_delimiter(p.kumiai_fee), number_with_delimiter(p.kumiai_fee_per), number_with_delimiter(p.hanbai_fee),
          number_with_delimiter(p.hanbai_fee_per), number_with_delimiter(p.seikyu), ""]
      end + [
        [ {content: "", colspan: 8}, {content: "出品数 : #{@company_products[c.id][:products].length}", colspan: 2}, {content: "合計金額", colspan: 3}, number_with_delimiter(@company_products[c.id][:products].sum(&:shiharai))],
        [ {content: "", colspan: 10}, {content: "消費税 : #{@open_now.tax}%", colspan: 3}, number_with_delimiter(@open_now.tax_calc(@company_products[c.id][:products].sum(&:shiharai)))],
        [ {content: "", colspan: 10}, {content: "差引出品支払額", colspan: 3}, number_with_delimiter(@open_now.tax_total(@company_products[c.id][:products].sum(&:shiharai)))],
      ]

      pdf.table arr, {
        header: true,
      } do |t|
        t.cells.style(size: 9)

        t.columns(0).style(width: 33,  align: :right)
        t.columns(1).style(width: 138, align: :left)
        t.columns(2).style(width: 60, align: :right)
        t.columns(3).style(width: 60, align: :right)
        t.columns(4).style(width: 67, align: :left)
        t.columns(5).style(width: 60, align: :right)

        t.columns(6).style(width: 64, align: :left)
        t.columns(7).style(width: 50, align: :right)
        t.columns(8).style(width: 21, align: :right)
        t.columns(9).style(width: 50, align: :right)
        t.columns(10).style(width: 21, align: :right)
        t.columns(11).style(width: 50, align: :right)
        t.columns(12).style(width: 21, align: :right)
        t.columns(13).style(width: 60, align: :right)
        t.columns(14).style(width: 40, align: :left)

        t.row(0).style(align: :left)

        t.row(0).columns([2, 11]).style(size: 7)
        t.row(0).columns([7, 9]).style(size: 7)
        t.row(0).columns(11).style(size: 5)

        t.row(-1).columns(0).border_width = 0
        t.row(-2).columns(0).border_width = 0
        t.row(-3).columns(0).border_width = 0
      end
    end

  end

  @companies.each do |c|
    next if @company_products[c.id][:products].blank? && @company_products[c.id][:success_products].blank?
    next if @company_products[c.id][:success_products].sum(&:seikyu) <= @company_products[c.id][:products].sum(&:shiharai)
    sashihiki = (@company_products[c.id][:products].sum(&:shiharai) - @company_products[c.id][:success_products].sum(&:seikyu)).abs
    total     = (@open_now.tax_total(products.sum(&:shiharai)) - @open_now.tax_total(success_products.sum(&:seikyu))).abs

    pdf.start_new_page layout: :portrait, margin: [8.mm]
    pdf.font "vendor/assets/fonts/ipaexm.ttf"

    [0, 148.mm].each do |side|
      pdf.bounding_box([0, side + (132.5).mm], width: 194.mm, height: (132.5).mm) do
        pdf.stroke_bounds

        pdf.text_box "#{c.name} 御中", {size: 16, at: [12.mm, (132.5- 16).mm]}
        pdf.stroke_line [12.mm, (132.5- 23).mm], [70.mm, (132.5- 23).mm]
        pdf.text_box (side == 0 ? "領収証(控)" : "領収証"), {size: 26, at: [0, (132.5- 27).mm], align: :center}
        pdf.text_box "下記の通り、御社の#{@open_now.name}の清算金額を領収いたしました。", {size: 12, at: [8.mm, (132.5- 38).mm]}
        pdf.text_box "記", {size: 12, at: [8.mm, (132.5- 52).mm], align: :center}

        pdf.bounding_box([8.mm, 212], width: 178.mm, height: 42.mm) do
          arr = [
            %w|請求金額(税抜) 消費税 合計請求金額|,
            [number_with_delimiter(sashihiki), number_with_delimiter(total - sashihiki), number_with_delimiter(total)]
          ]
          pdf.table arr do |t|
            t.cells.style(size: 15)

            t.row(0).style(size: 12, align: :center, valign: :middle)
            t.row(1).style(size: 16, height: 13.mm, align: :right, valign: :center)

            t.columns(0).style(width: 65.mm)
            t.columns(1).style(width: 43.mm)
            t.columns(2).style(width: 70.mm)
          end
        end

        pdf.bounding_box([8.mm, 50.mm], width: 56.mm, height: 42.mm) do
          arr = [ [{content: "内訳", rowspan: 2}, "", "現金"], ["", "小切手"] ]
          pdf.table arr do |t|
            t.cells.style(size: 12, align: :center)

            t.row([0, 1]).style(height: 8.mm)

            t.columns(0).style(width: 17.mm, valign: :center)
            t.columns(1).style(width: 8.mm)
            t.columns(2).style(width: 26.mm)
          end
        end

        pdf.bounding_box([8.mm, 50.mm], width: 178.mm, height: 42.mm) do
          # pdf.stroke_bounds

          pdf.default_leading 8

          pdf.text "以上", size: 12, align: :right
          pdf.text "平成　　年　　月　　日", size: 12, align: :right
          pdf.text "大阪機械卸業団地協同組合", size: 14, align: :right
          pdf.text "〒578-0965 東大阪市本庄西2-5-10", size: 12, align: :right
          pdf.text "TEL 06-6747-7521　FAX 06-6747-7525", size: 12, align: :right
        end
      end
    end
  end

end
