# == Schema Information
#
# Table name: areas
#
#  id                :integer          not null, primary key
#  image             :text
#  name              :string
#  order_no          :integer
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_areas_on_soft_destroyed_at  (soft_destroyed_at)
#
class Area < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  mount_uploader :image, ProductImageUploader

  has_many :products
end
