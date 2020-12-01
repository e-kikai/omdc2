# == Schema Information
#
# Table name: displays
#
#  id                :integer          not null, primary key
#  display           :boolean          default(FALSE)
#  label             :string
#  soft_destroyed_at :datetime
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_displays_on_label              (label)
#  index_displays_on_soft_destroyed_at  (soft_destroyed_at)
#
class Display < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  def self.check(label)
    find_by(label: label).display rescue false
  end
end
