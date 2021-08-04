# == Schema Information
#
# Table name: favorites
#
#  id                :bigint           not null, primary key
#  amount            :integer
#  host              :string
#  ip                :string
#  r                 :string
#  referer           :string
#  soft_destroyed_at :datetime
#  ua                :string
#  utag              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_favorites_on_product_id         (product_id)
#  index_favorites_on_soft_destroyed_at  (soft_destroyed_at)
#  index_favorites_on_user_id            (user_id)
#
require 'rails_helper'

RSpec.describe Favorite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
