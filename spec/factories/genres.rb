# == Schema Information
#
# Table name: genres
#
#  id                :integer          not null, primary key
#  capacity_label    :string
#  capacity_unit     :string
#  name              :string
#  naming            :string
#  order_no          :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  large_genre_id    :integer
#
# Indexes
#
#  index_genres_on_large_genre_id     (large_genre_id)
#  index_genres_on_soft_destroyed_at  (soft_destroyed_at)
#
FactoryBot.define do
  factory :genre do

  end
end
