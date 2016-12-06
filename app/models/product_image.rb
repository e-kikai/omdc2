class ProductImage < ApplicationRecord
  mount_uploader :image, ProductImageUploader

  belongs_to :product

  validate :product_images_number_of_product

  def product_images_number_of_product
    if product && product.product_images.count > 5
      errors.add(:product_image, " : 画像ファイルの数は1商品に5枚までです")
    end
  end
end
