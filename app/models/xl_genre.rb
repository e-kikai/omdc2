class XlGenre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :large_genres
  has_many :genre, through: :large_genre
end
