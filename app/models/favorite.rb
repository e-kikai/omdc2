# == Schema Information
#
# Table name: favorites
#
#  id                :bigint           not null, primary key
#  amount            :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_favorites_on_product_id         (product_id)
#  index_favorites_on_soft_destroyed_at  (soft_destroyed_at)
#  index_favorites_on_user_id            (user_id)
#
class Favorite < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user,    required: true
  belongs_to :product, required: true
  delegate   :open,   to: :product

  validates :user_id,    presence: true
  validates :product_id, presence: true

  validates :product_id, uniqueness: { message: "は、既にお気に入りに登録されています。", scope: [:user_id, :soft_destroyed_at] }

end
