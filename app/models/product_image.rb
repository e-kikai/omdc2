class ProductImage < ApplicationRecord
  NOIMAGE_THUMB = "noimg_thumb.png"

  mount_uploader :image, ProductImageUploader

  belongs_to :product

  validate :product_images_number_of_product

  def product_images_number_of_product
    if product && product.product_images.count > 5
      errors.add(:product_image, " : 画像ファイルの数は1商品に5枚までです")
    end
  end

  # def self.dump(filename)
  #   CSV.foreach(filename) do |row|
  #     begin
  #       ProductImage.transaction do
  #         img = Product.find(row[0]).product_images.new
  #         img.save!
  #         puts "http://122.103.211.133/bid_list/media/img/#{row[1]}"
  #         img.remote_image_url = "http://122.103.211.133/bid_list/media/img/#{row[1]}"
  #         img.save!
  #       end
  #     rescue => e
  #       puts e.message
  #     end
  #   end
  # end
end
