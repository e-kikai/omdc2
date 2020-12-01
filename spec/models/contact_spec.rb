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
require 'rails_helper'

RSpec.describe Contact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
