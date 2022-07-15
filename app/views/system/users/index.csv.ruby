header = %w[
  ID 会社名 氏名 メールアドレス 大ジャンルID
]

columns = %w|
  id company name email
|

CSV.generate do |row|
  row << header

  @users.reorder(:id).in_batches(of: 2000) do |uss|
    uss.pluck(columns).each do |us|
      ### 整形 ###
      us << @fav_xls[us[0]]

      row << us
    end
  end
end

# res