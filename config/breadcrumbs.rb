### ユーザ画面 ###
crumb :root do
  link "TOP", "/"
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
  link "#{product.name} #{product.maker} #{product.model} 商品詳細", "/detail/#{product.id}"
  parent :genre, product.genre
end

crumb :contact do |product|
  link "メールで問い合わせ", "/contact/#{product.id}"
  parent :detail, product
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

crumb :bid_bids_new do
  link   "入札", "/bid/bids/new"
  parent :bid_root
end
