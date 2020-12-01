# == Schema Information
#
# Table name: requests
#
#  id                :bigint           not null, primary key
#  amount            :integer
#  bided_at          :datetime
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :bigint
#  product_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_requests_on_company_id         (company_id)
#  index_requests_on_product_id         (product_id)
#  index_requests_on_soft_destroyed_at  (soft_destroyed_at)
#  index_requests_on_user_id            (user_id)
#
require 'rails_helper'

RSpec.describe Request, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
