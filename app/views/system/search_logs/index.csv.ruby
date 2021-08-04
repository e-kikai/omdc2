# %w[ID アクセス日時 IP ホスト名 utag ユーザID 会社名 ユーザ名
#   キーワード パス ページ数
#   リンク元 r リファラ].to_csv+
# @search_logs.sum do |lo|
#   [
#     lo.id, lo.created_at, lo.ip, lo.host, lo.utag, lo.user_id, lo.user&.company, lo.user&.name,
#     lo.keywords, lo.path, lo.page,
#     URI.unescape(lo.link_source), lo.r, URI.unescape(lo.referer).scrub('♪'),

#   ].to_csv
# end

header = %w[ID アクセス日時 IP ホスト名 utag ユーザID 会社名 ユーザ名
  キーワード パス ページ数
  リンク元 r リファラ]

CSV.generate do |row|
  row << header

  @search_logs.each do |lo|
    row << [
      lo.id, lo.created_at, lo.ip, lo.host, lo.utag, lo.user_id, lo.user&.company, lo.user&.name,
      lo.keywords, lo.path, lo.page,
      URI.unescape(lo.link_source), lo.r, URI.unescape(lo.referer).scrub('♪'),
      ]
  end
end