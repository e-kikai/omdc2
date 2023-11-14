%w|会社No. 会社名 登録番号 担当者 代表者 役職 〒 住所
  TEL FAX メールアドレス 備考 出品可否 支払方法 ログインアカウント 登録日時 変更日時|.to_csv +
@companies.sum do |c|
  [c.no, c.name, c.registration_number, c.charge, c.representative, c.position, c.zip, c.address,
    c.tel, c.fax, c.mail, c.memo, (c.entry ? "◯" : "×"), (c.transfer? ? "振込" : "小切手"), c.account, c.created_at, c.updated_at].to_csv
end
