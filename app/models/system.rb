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

  def self.qrcode_temp(url)
    qr = RQRCode::QRCode.new(url, size: 6, level: :l).as_png( 
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 50,
      border_modules: 0,
      module_px_size: 1,
      file: nil # path to write
    ).to_s

    file = Tempfile.open(["qr", ".png"])
    file.binmode
    file.write(qr)
    file.size
    file.path
  end
end
