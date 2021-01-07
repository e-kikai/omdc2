require 'stringio'

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

        pdf.text p.list_no, {size: 54}
        pdf.text "　", {size: 4, align: :center}
        pdf.text "#{p.name}", {size: 24, align: :center}

        pdf.font "vendor/assets/fonts/ipaexm.ttf"
        pdf.text "#{p.maker} #{p.year} #{p.model}", {size: 15, align: :center}

        # pdf.image System.qrcode_temp("#{root_url}qr?id=#{p.id}&place=hangtag"), at: [320, 262]
        # print_qr_code("#{root_url}qr?id=#{p.id}&place=hangtag", extent: 96, stroke: false, pos: [320, 262])
        # pdf.qrcode(RQRCode::QRCode.new("#{root_url}qr?id=#{p.id}&place=hangtag", size: 6, level: :l).as_png(
        #   resize_gte_to: false,
        #   resize_exactly_to: false,
        #   fill: 'white',
        #   color: 'black',
        #   size: 50,
        #   border_modules: 0,
        #   module_px_size: 1,
        #   file: nil # path to write
        # ))

        qr_url = "#{root_url}qr?id=#{p.id}&place=hangtag"
        # qr_url = "#{root_url}products/#{p.id}?r=qr"

        qr_image =
        RQRCode::QRCode.new(qr_url, size: 6, level: :l).as_png(
              resize_gte_to: false,
              resize_exactly_to: false,
              fill: 'white',
              color: 'black',
              size: 50,
              border_modules: 0,
              module_px_size: 1,
              file: nil # path to write
            ).to_s
        pdf.image StringIO.new(qr_image), at: [320, 262]

        pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
        pdf.text_box "最低入札金額", {size: 17, at: [0, 60]}
        pdf.text_box "￥#{number_with_delimiter(p.min_price)}", {size: 27, at: [110, 68]}
        pdf.text_box "落札会社 :", {size: 23, at: [0, 30]}

        pdf.text_box "#{p.company.no}-#{p.app_no}", {size: 14, at: [320, 16]}
      end
    end

    i = i + 1
  end
end
