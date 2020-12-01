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
class XlGenre < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :large_genres
  has_many :genres,   through: :large_genres
  has_many :products, through: :genres

  validates :name,                 presence: true

end
