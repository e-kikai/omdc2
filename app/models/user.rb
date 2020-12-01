# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  addr                   :string
#  allow_mail             :boolean          default(TRUE)
#  company                :string           not null
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  fax                    :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  soft_destroyed_at      :datetime
#  tel                    :string
#  unconfirmed_email      :string
#  zip                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :bigint
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_soft_destroyed_at     (soft_destroyed_at)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable, :confirmable

  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :company, required: false

  has_many :favorites
  has_many :requests
  has_many :chats
  has_many :contacts
  has_many :detail_logs
  has_many :search_logs
  has_many :toppage_logs

  has_many   :industry_users, dependent: :destroy
  has_many   :industries,     through:   :industry_users
  has_many   :genre_users,    dependent: :destroy
  has_many   :genres,         through:   :genre_users

  accepts_nested_attributes_for :industry_users, allow_destroy: true
  accepts_nested_attributes_for :genre_users,    allow_destroy: true


end
