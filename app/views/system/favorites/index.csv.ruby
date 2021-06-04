%w|ID ユーザID 会社名 氏名 登録日時 削除日時|
  .concat(render("/system/detail_logs/product", product: nil)).to_csv +
@favorites.sum do |fa|
  [fa.id, fa.user_id, fa.user&.company, fa.user&.name, fa.created_at, fa.soft_destroyed_at]
    .concat(render("/system/detail_logs/product", product: fa&.product)).to_csv
end.to_s
