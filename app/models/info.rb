class Info < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  def self.comment(label)
    find_by(label: label).comment rescue ""
  end
end
