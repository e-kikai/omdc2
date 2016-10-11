class Genre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :large_genre
  has_one    :xl_genre,   through: :large_genre

  def self.options
    all.includes(:large_genre, :xl_genre).order("xl_genres.order_no, large_genres.order_no, genres.order_no").map do |g|
      ["#{g.xl_genre.name} > #{g.large_genre.name} > #{g.name}", g.id]
    end
  end
end
