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
class Genre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :large_genre
  has_one    :xl_genre,   through: :large_genre
  has_many   :products

  validates :name,                 presence: true


  def self.options
    all.includes(:large_genre, :xl_genre).order("xl_genres.order_no, large_genres.order_no, genres.order_no").map do |g|
      ["#{g.xl_genre.name} > #{g.large_genre.name} > #{g.name}", g.id]
    end
  end
end
