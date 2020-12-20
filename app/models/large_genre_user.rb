# == Schema Information
#
# Table name: large_genre_users
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  large_genre_id :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_large_genre_users_on_large_genre_id  (large_genre_id)
#  index_large_genre_users_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (large_genre_id => genres.id)
#  fk_rails_...  (user_id => users.id)
#
class LargeGenreUser < ApplicationRecord
  belongs_to :user
  belongs_to :large_genre
end
