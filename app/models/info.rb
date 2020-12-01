# == Schema Information
#
# Table name: infos
#
#  id                :integer          not null, primary key
#  comment           :text
#  label             :string
#  soft_destroyed_at :datetime
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_infos_on_label              (label)
#  index_infos_on_soft_destroyed_at  (soft_destroyed_at)
#
class Info < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  def self.comment(label)
    find_by(label: label).comment rescue ""
  end
end
