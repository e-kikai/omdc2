# == Schema Information
#
# Table name: opens
#
#  id                   :integer          not null, primary key
#  addr                 :text             default("東大阪市本庄中2-2-38"), not null
#  bid_end_at           :datetime         not null
#  bid_start_at         :datetime         not null
#  billing_date         :date             not null
#  carry_in_end_date    :date             not null
#  carry_in_start_date  :date             not null
#  carry_out_end_date   :date             not null
#  carry_out_start_date :date             not null
#  entry_end_date       :date             not null
#  entry_start_date     :date             not null
#  fax                  :text             default("06-6747-7529"), not null
#  lower_price          :integer          default(20000)
#  name                 :string           default(""), not null
#  owner                :string           default("大阪機械卸業団地協同組合"), not null
#  payment_date         :date             not null
#  place                :text             default("大阪機械卸業団地協同組合 共同展示場"), not null
#  preview_end_date     :date             not null
#  preview_start_date   :date             not null
#  product_rate         :integer          default(1000), not null
#  rate                 :integer          default(1000)
#  result               :boolean          default(FALSE), not null
#  soft_destroyed_at    :datetime
#  tax                  :integer          default(8)
#  tel                  :text             default("06-6747-7528"), not null
#  user_bid_end_at      :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_opens_on_soft_destroyed_at  (soft_destroyed_at)
#
FactoryBot.define do
  factory :open do
    name "MyString"
    owner "MyString"
    lower_price 1
    rate 1
    tax 1
    entry_start_at "2016-09-07 15:47:46"
    entry_end_at "2016-09-07 15:47:46"
    preview_start_date "2016-09-07"
    preview_end_date "2016-09-07"
    bid_start_at "2016-09-07 15:47:46"
    bid_end_at "2016-09-07 15:47:46"
    user_bid_end_at "2016-09-07 15:47:46"
  end
end
