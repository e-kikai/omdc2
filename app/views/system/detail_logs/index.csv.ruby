%w[ID アクセス日時 IP ホスト名 ユーザID 会社名 ユーザ名
  リンク元 r リファラ]
  .concat(render("/system/detail_logs/product", product: nil)).to_csv+
@detail_logs.sum do |lo|
  [
    lo.id, lo.created_at, lo.ip, lo.host, lo.user_id, lo.user&.company, lo.user&.name,
    URI.unescape(lo.link_source), lo.r, URI.unescape(lo.referer).scrub('♪'),

  ].concat(render("/system/detail_logs/product", product: lo&.product)).to_csv
end
