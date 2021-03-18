%w|ページ ページビュー数 ページ別訪問数|.to_csv +
@detail_logs.sum do |key, val|
  [key, val, @detail_users[key]].to_csv
end.to_s
