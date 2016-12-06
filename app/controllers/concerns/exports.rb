module Exports
  extend ActiveSupport::Concern

  require 'nkf'

  # 共通CSVエクスポート処理
  def export_csv(filename = nil, path = nil)
    send_data NKF::nkf('--sjis -Lw', render_to_string(path)),
      content_type: 'text/csv;charset=shift_jis',
      filename: filename
  end

  # 共通PDFエクスポート処理
  def export_pdf(filename = nil, path = nil)
    kit = PDFKit.new(render_to_string(path, layout: false), encoding: "UTF-8")

    kit.stylesheets << "#{Rails.root}/vendor/assets/stylesheets/bootstrap_for_pdf.min.css"
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/pdf.css"

    send_data kit.to_pdf,
      filename:     filename,
      content_type: "application/pdf",
      disposition:  "inline"
  end
end
