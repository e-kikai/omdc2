# == Schema Information
#
# Table name: contacts
#
#  id                :bigint           not null, primary key
#  addr_1            :string
#  allow_mail        :boolean          default(TRUE)
#  company           :string           not null
#  content           :text             not null
#  host              :string           default("")
#  ip                :string           default("")
#  mail              :string           not null
#  name              :string           not null
#  soft_destroyed_at :datetime
#  tel               :string
#  ua                :string           default("")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint
#
# Indexes
#
#  index_contacts_on_soft_destroyed_at  (soft_destroyed_at)
#  index_contacts_on_user_id            (user_id)
#
class Contact < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user,    required: false

end
