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
