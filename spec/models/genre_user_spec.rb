# == Schema Information
#
# Table name: genre_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  genre_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_genre_users_on_genre_id  (genre_id)
#  index_genre_users_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (genre_id => genres.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe GenreUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
