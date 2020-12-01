# == Schema Information
#
# Table name: large_genres
#
#  id                :integer          not null, primary key
#  hide_option       :string
#  name              :string
#  order_no          :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  xl_genre_id       :integer
#
# Indexes
#
#  index_large_genres_on_soft_destroyed_at  (soft_destroyed_at)
#  index_large_genres_on_xl_genre_id        (xl_genre_id)
#
FactoryBot.define do
  factory :large_genre do

  end
end
