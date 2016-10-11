class Company < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [ :account ]

  soft_deletable
  default_scope { without_soft_destroyed }

  has_many :products
  has_many :bids

  validates :name,    presence: true
  validates :no,      presence: true, uniqueness: { scope: [:soft_destroyed_at] }, numericality: { only_integer: true }
  validates :account, presence: true, uniqueness: { scope: [:soft_destroyed_at] }
  validates :email,   presence: false

  _validators.delete(:email)
  _validate_callbacks.each do |callback|
    if callback.raw_filter.respond_to? :attributes
      callback.raw_filter.attributes.delete :email
    end
  end

  def self.find_for_authentication(warden_conditions)
    without_soft_destroyed.where(account: warden_conditions[:account]).first
  end
end
