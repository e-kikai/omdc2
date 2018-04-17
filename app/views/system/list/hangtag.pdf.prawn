prawn_document do |pdf|
  sage_height = 595.28 / 2
  sage_width  = 841.89 / 2

  i = 0
  @products.each.with_index do |p, j|
    if i % 4 == 0 || p.company.no != @products[j-1].company.no
      pdf.start_new_page layout: :landscape, margin: [0]
      pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      i = 0

      # pdf.stroke_axis
      pdf.default_leading 4
    end

    pdf.bounding_box([(i % 2 * sage_width), ((2 - i.div(2) ) * sage_height)], width: sage_width, height: sage_height) do
      # pdf.stroke_bounds

      pdf.bounding_box([6.mm, sage_height - 6.mm], width: sage_width - 12.mm, height: sage_height- 12.mm) do
        # pdf.stroke_bounds

        pdf.text p.list_no, {size: 48}
        pdf.text "　", {size: 12, align: :center}
        pdf.text "#{p.name}", {size: 21, align: :center}

        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        pdf.text "#{p.maker} #{p.year} #{p.model}", {size: 13, align: :center}

        pdf.image System.qrcode_temp("#{root_url}qr?id=#{p.id}&place=hangtag"), at: [320, 262]

        pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
        pdf.text_box "最低入札金額", {size: 17, at: [0, 60]}
        pdf.text_box "￥#{number_with_delimiter(p.min_price)}", {size: 27, at: [110, 68]}
        pdf.text_box "落札会社 :", {size: 27, at: [0, 30]}

        pdf.text_box "#{p.company.no}-#{p.app_no}", {size: 14, at: [320, 16]}
      end
    end

    i = i + 1
  end
end
