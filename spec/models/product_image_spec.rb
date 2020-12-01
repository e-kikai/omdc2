# == Schema Information
#
# Table name: product_images
#
#  id         :integer          not null, primary key
#  image      :text
#  order_no   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer          not null
#
# Indexes
#
#  index_product_images_on_product_id  (product_id)
#
require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
