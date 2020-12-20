prawn_document do |pdf|

  ### 初期化 ###
  pdf.start_new_page layout: :portrait, margin: [10.mm, 15.mm]
  pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"


  pdf.default_leading 2
  pdf.stroke_axis

  pdf.text "発行日 #{Date.today}", size: 12, align: :right
  pdf.text "入　札　依　頼　書", size: 24, align: :center
  pdf.move_down 20

  pdf.text "御中", size: 14
  # pdf.move_down 20
  pdf.text current_user.company, size: 14, align: :right

  pdf.text "下記の商品の入札を依頼します。", size: 14
  pdf.move_down 20

  pdf.text @open_now.name, size: 14

  pdf.table @favorites, header: true
end
