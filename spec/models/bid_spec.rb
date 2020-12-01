# == Schema Information
#
# Table name: bids
#
#  id                :integer          not null, primary key
#  amount            :integer
#  charge            :string
#  comment           :text
#  sameno            :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :integer
#  product_id        :integer
#
# Indexes
#
#  index_bids_on_company_id         (company_id)
#  index_bids_on_product_id         (product_id)
#  index_bids_on_soft_destroyed_at  (soft_destroyed_at)
#
require 'rails_helper'

RSpec.describe Bid, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
