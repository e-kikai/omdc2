class Bid < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :product
  belongs_to :company
  delegate   :open,   to: :product

end
