prawn_document do |pdf|

  ### 初期化 ###
  pdf.start_new_page layout: :portrait, margin: [10.mm, 12.mm]
  pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"

  pdf.default_leading 2
  # pdf.stroke_axis

  pdf.text "発行日 #{Date.today}", size: 12, align: :right
  pdf.text "入　札　依　頼　書", size: 24, align: :center
  pdf.move_down 20

  pdf.text "　　　　　　　　　　　　　　御中", size: 14
  # pdf.move_down 20
  pdf.text current_user.company, size: 14, align: :right

  pdf.text "下記の商品の入札を依頼します。", size: 14
  pdf.move_down 20

  pdf.text @open_now.name, size: 14

  ### テーブル整形 ###
  w = (pdf.bounds.right / 20).floor
  ws = [w*2, w*5, w*3, w*3, w*3, w*4]

  min_price_sum = 0
  amount_sum    = 0
  table_data =  [["No.", "商品名", "メーカー", "最低入札金額", "入札依頼金額", "備考欄"]]
  @products.each do |pr|
    amount = @amounts[pr.id.to_s].to_i
    if amount > 0
      table_data << [pr.list_no, pr.name ,pr.maker, number_to_currency(pr.min_price), number_to_currency(amount), ""]
      min_price_sum += pr.min_price
      amount_sum    += amount
    end
  end
  table_data << ["", "", "小計", number_to_currency(min_price_sum), number_to_currency(amount_sum), ""]
  table_data << ["", "", "", "消費税(#{@open_now.tax}%)", number_to_currency(@open_now.tax_calc(amount_sum)), ""]
  table_data << ["", "", "", "合計", number_to_currency(@open_now.tax_total(amount_sum)), ""]

  ### テーブル生成 ###
  pdf.table(
    table_data,
    header: true,
    column_widths: ws,
    cell_style: { padding: [8, 6, 8, 6] }

  ) do |t|
    t.columns(0).style align: :right, size: 11
    t.columns(1).style align: :left,  size: 11
    t.columns(2).style align: :left,  size: 11
    t.columns(3).style align: :right, size: 11
    t.columns(4).style align: :right, size: 11
    t.columns(5).style align: :left,  size: 11

    t.row(-1).border_top_width = 2
    t.row(-2).border_top_width = 2
    t.row(-3).border_top_width = 2

    t.before_rendering_page do |page|
      page.row(0).border_top_width = 2
      page.row(0).border_bottom_width = 2
      page.row(-1).border_bottom_width = 2
      page.column(0).border_left_width = 2
      page.column(-1).border_right_width = 2
    end
  end

  # foot
  pdf.number_pages "<page> / <total>", { at: [0, 0], align: :center }
end
