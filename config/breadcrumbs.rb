
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
