class LargeGenre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :xl_genre
  has_many   :genres
  has_many   :products, through: :genres

  validates :name,                 presence: true
end
