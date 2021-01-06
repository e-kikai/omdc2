# 出力先のログファイルの指定
# set :output, 'log/crontab.log'
set :output, nil

# 事故防止の為RAILS_ENVの指定が無い場合にはdevelopmentを使用する
rails_env = ENV['RAILS_ENV'].to_s.to_sym || :development
set :environment, rails_env

# path = case rails_env
# when :production; "/var/www/omdc2/"
# else;             "/var/www/omdc2/current/"
# end
# set :path, path

### wget URL ###
url = case rails_env
when :production; "https://www.xn--4bswgw9cs82at4b485i.jp"
when :staging;    "http://52.198.41.71"
else;             "http://127.0.0.1:8082"
end

scheduling_url = url + "/system/scheduling"

# sitemap
# every 1.day, at: '5:00 am' do
#   rake '-s sitemap:refresh'
# end

### ベクトル一括変換 ###
every :day, at: '2:00 am' do
  command "curl -s -X POST #{scheduling_url + '/vectors_process'}"
end

# Twitter自動投稿
if rails_env == :production
  # every :friday, at: '4:00 pm' do
  #   command "wget --spider #{scheduling_url + '/news_mail'}"
  # end
end
