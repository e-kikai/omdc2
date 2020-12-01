# == Schema Information
#
# Table name: chats
#
#  id                :bigint           not null, primary key
#  comment           :text             not null
#  soft_destroyed_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_chats_on_company_id         (company_id)
#  index_chats_on_soft_destroyed_at  (soft_destroyed_at)
#  index_chats_on_user_id            (user_id)
#
class Chat < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user,    required: true
  belongs_to :company, required: true

end
