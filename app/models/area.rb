class Area < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  mount_uploader :image, ProductImageUploader

  has_many :products
end
