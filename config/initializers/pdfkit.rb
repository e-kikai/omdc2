PDFKit.configure do |config|
  config.wkhtmltopdf = `which wkhtmltopdf`.to_s.strip
  config.default_options = {
    encoding:                "UTF-8",  # エンコーディング
    # page_size:               "A4",     # ページのサイズ
    page_width:  "210mm",
    page_height: "297mm",
    # margin_top:              "0.25in", # 余白の設定
    # margin_right:            "0.25in",
    # margin_bottom:           "0.25in",
    # margin_left:             "0.25in",
    margin_top:              "12.9mm", # 余白の設定
    margin_right:            "6mm",
    margin_bottom:           "12.9mm",
    margin_left:             "6mm",
    disable_smart_shrinking: true
  }
end
