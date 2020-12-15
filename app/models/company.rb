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
#  remember_created_at    :datetime
#  representative         :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  soft_destroyed_at      :datetime
#  tel                    :string
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
  has_many :users, foreign_key: :window_id
  has_many :requests


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

  def name_remove_kabu
    name.gsub(/[（(][株有][）)]/, "")
  end
end
