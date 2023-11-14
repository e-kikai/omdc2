# == Schema Information
#
# Table name: companies
#
#  id                     :integer          not null, primary key
#  account                :string           default(""), not null
#  address                :string
#  charge                 :string
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  entry                  :boolean          default(FALSE)
#  fax                    :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  mail                   :string
#  memo                   :text
#  name                   :string
#  no                     :integer
#  position               :string
#  registration_number    :string           default(""), not null
#  remember_created_at    :datetime
#  representative         :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  soft_destroyed_at      :datetime
#  tel                    :string
#  transfer               :boolean          default(FALSE)
#  zip                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_companies_on_account_and_soft_destroyed_at  (account,soft_destroyed_at) UNIQUE
#  index_companies_on_no_and_soft_destroyed_at       (no,soft_destroyed_at) UNIQUE
#  index_companies_on_soft_destroyed_at              (soft_destroyed_at)
#
require 'rails_helper'

RSpec.describe Company, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
