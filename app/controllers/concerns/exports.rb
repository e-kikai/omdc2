module Exports
  extend ActiveSupport::Concern

  require 'nkf'

  # 共通CSVエクスポート処理
  def export_csv(filename = nil, path = nil)
    send_data NKF::nkf('--sjis -Lw', render_to_string(path)),
      content_type: 'text/csv;charset=shift_jis',
      filename: filename_encode(filename)
  end

  # 共通PDFエクスポート処理
  def export_pdf(filename = nil, path = nil, options = {})
    kit = PDFKit.new(render_to_string(path, layout: false), options)

    # kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/bootstrap_for_pdf.min.css"
    # kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"

    send_data kit.to_pdf,
      # filename:     filename_encode(filename),
      filename:     "test.pdf",
      content_type: "application/pdf",
      disposition:  "inline"
  end

  def filename_encode(filename)
    if (/MSIE/ =~ request.user_agent) || (/Trident/ =~ request.user_agent)
      ERB::Util.url_encode(filename)
    else
      filename
    end
  end
end
