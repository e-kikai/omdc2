["会社名", "氏名", "メールアドレス", "TEL", "郵便番号", "住所", "パスワード"].to_csv +
@users.sum do |us|
  [us.company, us.name, us.email, us.tel, us.zip, us.address, ""].to.csv
end
