prawn_document do |pdf|
  ef_width  = (595.28 - 6.mm * 2) / 3
  ef_height = (841.89 - (12.9).mm * 2) / 8

  i = 0
  params[:num].to_i.times.each do |n|
    pdf.start_new_page layout: :portrait, margin: [(12.9).mm, 6.mm]
    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"

    # pdf.stroke_axis

    (1..24).each do |m|
      pdf.bounding_box([((m - 1) % 3 * ef_width), ((8 - (m - 1) .div(3) ) * ef_height)], width: ef_width, height: ef_height) do
        # pdf.stroke_bounds

        pdf.bounding_box([0, ef_height], width: 120, height: ef_height) do
          pdf.text "#{@company.no}-#{n*24+m}", size: 28, valign: :center
        end
        pdf.image System.qrcode_temp("#{root_url}qr?key=#{@open_now.id}-#{@company.no}-#{n*24+m}&place=ef"), at: [120, 79], width: 64
      end
    end
  end
end
