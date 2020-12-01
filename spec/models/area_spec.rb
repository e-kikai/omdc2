# == Schema Information
#
# Table name: areas
#
#  id                :integer          not null, primary key
#  image             :text
#  name              :string
#  order_no          :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_areas_on_soft_destroyed_at  (soft_destroyed_at)
#
require 'rails_helper'

RSpec.describe Area, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
