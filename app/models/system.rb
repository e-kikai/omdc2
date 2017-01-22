class System < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [ :account ]

  soft_deletable
  default_scope { without_soft_destroyed }

  validates :name,                 presence: true

  def self.qrcode(url)
    RQRCode::QRCode.new(url, size: 4, level: :l).as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 70,
      border_modules: 0,
      module_px_size: 2,
      file: nil # path to write
    ).to_data_url
  end
end
