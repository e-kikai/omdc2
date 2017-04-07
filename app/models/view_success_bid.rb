class ViewSuccessBid < ApplicationRecord
  belongs_to :product, required: true
  belongs_to :company, required: true

end
