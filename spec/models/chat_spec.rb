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
require 'rails_helper'

RSpec.describe Chat, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
