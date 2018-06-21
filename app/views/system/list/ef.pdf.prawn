require 'barby/barcode/code_128'
require 'barby/outputter/prawn_outputter'

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
        pdf.stroke_bounds

        ### 文字 ###
        pdf.bounding_box([16, 96], width: 140, height: 40) do
          pdf.stroke_bounds

          pdf.text "#{@open_now.id}-", size: 12
          pdf.text "#{@company.no}-#{n*24+m}", size: 25
        end

        ### バーコード ###
        # pdf.image System.qrcode_temp("#{root_url}qr?key=#{@open_now.id}-#{@company.no}-#{n*24+m}&place=ef"), at: [120, 79], width: 64

        barcode = Barby::Code128B.new("#{@open_now.id}-#{@company.no}-#{n*24+m}")
        outputter = Barby::PrawnOutputter.new(barcode)
        outputter.annotate_pdf(pdf, x: 16, y: 16, xdim: 1, height: 40)
      end
    end
  end
end
