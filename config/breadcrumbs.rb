### ユーザ画面 ###
crumb :root do
  link "機械入札工具会", "/"
end

crumb :something do |title|
  link   title
  parent :root
end

crumb :search do |q|
  link   "検索結果", search_path(q: q)
  parent :root
end

crumb :xl_genre do |xl_genre|
  link   xl_genre.name, "/xl_genre/#{xl_genre.id}"
  parent :root
end

crumb :large_genre do |large_genre|
  link   large_genre.name, "/large_genre/#{large_genre.id}"
  parent :xl_genre, large_genre.xl_genre
end

crumb :genre do |genre|
  link   genre.name, "/genre/#{genre.id}"
  parent :large_genre, genre.large_genre
end

crumb :detail do |product|
  link "No.#{product.list_no} #{product.name} 商品詳細", "/detail/#{product.id}"
  parent :genre, product.genre
end

crumb :product_show do |product|
  link "No.#{product.list_no} #{product.name} 商品詳細", "/products/#{product.id}"
  parent :genre, product.genre
end

# crumb :contact do |product|
#   link "メールで問い合わせ", "/contact/#{product.id}"
#   parent :detail, product
# end

crumb :contact do
  link   "事務局への問い合わせ"
  parent :root
end

crumb :contact_fin do
  link   "問い合わせ完了"
  parent :contact
end

### 管理者画面 ###
crumb :system_root do
  link "管理者メニュー", "/system/"
end

crumb :system_something do |title|
  link   title
  parent :system_root
end

crumb :system_opens do
  link   "入札会一覧", "/system/opens/"
  parent :system_root
end

crumb :system_opens_show do |open|
  link   "#{open.name} 落札結果一覧", "/system/opens/#{open.id}"
  parent :system_opens
end

crumb :system_opens_result_detail do |product|
  link   "No.#{product.list_no} #{product.name} 入札詳細", "/system/opens/#{product.open.id}/detail/#{product.id}"
  parent :system_opens_show, product.open
end

crumb :system_opens_new do
  link   "新規登録", "/system/opens/new"
  parent :system_opens
end

crumb :system_opens_edit do |open|
  link   "#{open.name}", "/system/opens/#{open.id}/edit"
  parent :system_opens
end

crumb :system_companies do
  link   "会社一覧", "/system/companies/"
  parent :system_root
end

crumb :system_companies_new do
  link   "新規登録", "/system/companies/new"
  parent :system_companies
end

crumb :system_companies_edit do |company|
  link   "#{company.name}", "/system/companies/#{company.id}/edit"
  parent :system_companies
end

crumb :system_areas do
  link   "エリア一覧", "/system/areas/"
  parent :system_root
end

crumb :system_areas_new do
  link   "新規登録", "/system/areas/new"
  parent :system_areas
end

crumb :system_areas_edit do |area|
  link   "#{area.name}", "/system/areas/#{area.id}/edit"
  parent :system_areas
end

crumb :system_products do
  link   "出品商品一覧", "/system/products/"
  parent :system_root
end

crumb :system_products_new do
  link   "新規登録", "/system/products/new"
  parent :system_products
end

crumb :system_products_edit do |product|
  link   "#{product.name}", "/system/products/#{product.id}/edit"
  parent :system_products
end

crumb :system_products_csv do
  link   "CSV一括登録", "/system/products/csv"
  parent :system_products
end

crumb :system_products_csv_upload do
  link   "登録確認", "/system/products/csv"
  parent :system_products_csv
end

crumb :system_bids do
  link   "入札履歴", "/system/bids"
  parent :system_bids_new
end

crumb :system_bids_edit do
  link   "入札訂正", "/system/bids/edit"
  parent :system_bids
end

crumb :system_bids_new do
  link   "入札", "/system/bids/new"
  parent :system_root
end


#### 組合員ページ ####
crumb :bid_root do
  link "組合員メニュー", "/bid/"
end

crumb :bid_something do |title|
  link   title
  parent :bid_root
end

crumb :bid_products do
  link   "出品商品一覧", "/bid/products/"
  parent :bid_root
end

crumb :bid_products_new do
  link   "新規登録", "/bid/products/new"
  parent :bid_products
end

crumb :bid_products_edit do |product|
  link   "#{product.name}", "/bid/products/#{product.id}/edit"
  parent :bid_products
end

crumb :bid_products_csv do
  link   "CSV一括登録", "/bid/products/csv"
  parent :bid_products
end

crumb :bid_products_csv_upload do
  link   "登録確認", "/bid/products/csv"
  parent :bid_products_csv
end

crumb :bid_bids do
  link   "入札履歴", "/bid/bids"
  parent :bid_bids_new
end

crumb :bid_bids_edit do
  link   "入札訂正", "/bid/bids/edit"
  parent :bid_bids
end

crumb :bid_bids_new do
  link   "入札", "/bid/bids/new"
  parent :bid_root
end

crumb :bid_opens do
  link   "過去の入札会一覧", "/bid/opens/"
  parent :bid_root
end

crumb :bid_opens_show do |open|
  link   "#{open.name} 落札結果一覧", "/system/opens/#{open.id}"
  parent :bid_opens
end
crumb :bid_users do
  link   "取引ユーザ一覧", "/bid/users/"
  parent :bid_root
end

crumb :bid_users_new do
  link   "新規登録", "/bid/users/new"
  parent :bid_users
end

crumb :bid_users_edit do |users|
  link   "#{users.company} #{users.name}", "/bid/users/#{users.id}/edit"
  parent :bid_users
end

crumb :bid_users_csv do
  link   "CSV一括登録", "/bid/users/csv"
  parent :bid_users
end

crumb :bid_users_csv_upload do
  link   "登録確認", "/bid/users/csv"
  parent :bid_users_csv
end

crumb :bid_requests do
  link   "入札依頼一覧", "/bid/requests/"
  parent :bid_root
end

crumb :bid_requests_user do |user|
  link   "#{user.company} #{user.name}", "/bid/requests?user_id=#{user.id}"
  parent :bid_requests
end

crumb :bid_requests_bid do |request|
  link   "入札", "/bid/requests/#{request.id}"
  parent :bid_requests_user, request.user
end


### マイページ ###
crumb :mypage do
  link   "マイページ", "/mypage/"
  parent :root
end

crumb :mypage_something do |title|
  link   title
  parent :mypage_root
end

crumb :mypage_favolite do
  link   "お気に入り一覧", "/mypage/favorites"
  parent :mypage_root
end

crumb :mypage_contact do
  link   "事務局への問い合わせ"
  parent :mypage_root
end

crumb :mypage_contact_fin do
  link   "問い合わせ完了"
  parent :mypage_contact
end

crumb :mypage_user_edit do
  link   "ユーザ情報変更", "/mypage/user/edit"
  parent :mypage_root
end
