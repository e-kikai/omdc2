class Display < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  def self.check(label)
    find_by(label: label).display rescue false
  end
end
