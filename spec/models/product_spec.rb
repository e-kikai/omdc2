# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  accessory         :string
#  app_no            :integer
#  bids_count        :integer          default(0)
#  carryout_at       :datetime
#  comment           :text
#  condition         :text
#  display           :integer          default("一般出品"), not null
#  featured          :boolean          default(FALSE), not null
#  hitoyama          :boolean          default(FALSE)
#  list_no           :integer
#  maker             :string
#  min_price         :integer
#  model             :string
#  name              :string
#  pdfs              :string
#  same_count        :integer          default(0)
#  soft_destroyed_at :datetime
#  spec              :string
#  year              :string
#  youtube           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  area_id           :integer
#  company_id        :integer          not null
#  genre_id          :integer          default(390), not null
#  open_id           :integer          not null
#  success_bid_id    :integer
#
# Indexes
#
#  index_products_on_company_id         (company_id)
#  index_products_on_open_id            (open_id)
#  index_products_on_soft_destroyed_at  (soft_destroyed_at)
#
require 'rails_helper'

RSpec.describe Product, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
