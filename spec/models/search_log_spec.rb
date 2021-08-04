# == Schema Information
#
# Table name: search_logs
#
#  id         :bigint           not null, primary key
#  host       :string
#  ip         :string
#  keywords   :string           default(""), not null
#  page       :string           default("1"), not null
#  path       :string           default(""), not null
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string
#  utag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_search_logs_on_user_id  (user_id)
#
require 'rails_helper'

RSpec.describe SearchLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
