class XlGenre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :large_genres
  has_many :genres,   through: :large_genres
  has_many :products, through: :genres

  validates :name,                 presence: true

end
