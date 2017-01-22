class Display < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

end
