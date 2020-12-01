# == Schema Information
#
# Table name: systems
#
#  id                     :integer          not null, primary key
#  account                :string           default(""), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  soft_destroyed_at      :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_systems_on_account_and_soft_destroyed_at  (account,soft_destroyed_at) UNIQUE
#  index_systems_on_soft_destroyed_at              (soft_destroyed_at)
#
FactoryBot.define do
  factory :system do

  end
end
