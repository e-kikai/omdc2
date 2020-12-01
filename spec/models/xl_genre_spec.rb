# == Schema Information
#
# Table name: xl_genres
#
#  id                :integer          not null, primary key
#  name              :string
#  order_no          :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_xl_genres_on_soft_destroyed_at  (soft_destroyed_at)
#
require 'rails_helper'

RSpec.describe XlGenre, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
