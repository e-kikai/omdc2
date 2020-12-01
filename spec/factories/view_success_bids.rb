# == Schema Information
#
# Table name: view_success_bids
#
#  id                :integer
#  amount            :integer
#  charge            :string
#  comment           :text
#  count             :bigint
#  same_count        :bigint
#  sameno            :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  company_id        :integer
#  product_id        :integer
#
FactoryBot.define do
  factory :view_success_bid do

  end
end
