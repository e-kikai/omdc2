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
#  window_id              :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_soft_destroyed_at     (soft_destroyed_at)
#  index_users_on_window_id             (window_id)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable, :confirmable

  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :window, class_name: "Company", required: false

  has_many :favorites
  has_many :requests
  has_many :chats
  has_many :contacts
  has_many :detail_logs
  has_many :search_logs
  has_many :toppage_logs

  has_many   :industry_users,    dependent: :destroy
  has_many   :industries,        through:   :industry_users
  has_many   :large_genre_users, dependent: :destroy
  has_many   :large_genres,      through:   :large_genre_users

  accepts_nested_attributes_for :industry_users,    allow_destroy: true
  accepts_nested_attributes_for :large_genre_users, allow_destroy: true

  validates :company, presence: true
  validates :name,    presence: true

  validates :allow_mail, inclusion: {in: [true, false]}

  _validators.delete(:email)
  _validate_callbacks.each do |callback|
    if callback.raw_filter.respond_to? :attributes
      callback.raw_filter.attributes.delete :email
    end
  end

  # emailのバリデーションを定義し直す
  validates :email, presence: true
  validates_format_of :email, with: Devise.email_regexp, if: :email_changed?
  validates_uniqueness_of :email, scope: :soft_destroyed_at, if: :email_changed?

  after_create :mailmagazine_create
  after_update :mailmagazine_update

  ### 一括登録 ###
  # def self.import_conf(file)
  #   res = []
  #   CSV.map(file.path, { :headers => true, encoding: Encoding::SJIS }) do |row|
  #     user = find_or_initialize_by(email: row[2])
  #
  #     status = case
  #     when user.company_id;
  #
  #     user.attributes =  {
  #       company:   row[0],
  #       name:      row[1],
  #       email:     row[2],
  #       tel:       row[3],
  #       zip:       row[4],
  #       address:   row[5],
  #       password:  row[6],
  #     }
  #
  #     product.set_display(row[10])
  #     # product.set_genre
  #     product.set_genre if product.genre_id == 390
  #
  #     product.valid?
  #     product
  #   end
  # end
  #
  # def self.import(products)
  #   products.each do |p|
  #     find_or_initialize_by(app_no: p[:app_no]).update!(p)
  #   end
  # end

  ### お気に入りリストIDリスト ###
  def favorite_ids
    favorites.pluck(:product_id)
  end

  def favorite?(product_id)
    @favorite_ids = favorites.pluck(:product_id) if @favorite_ids.nil?

    @favorite_ids.include?(product_id)
  end

  def mailmagazine_create
    if self.allow_mail
      mm = MailMagazine.new
      mm.add_member(self, email)
    end
  # rescue => e
  end

  def mailmagazine_update
    logger.debug "########## changed allow mail #{email}"

    if saved_change_to_allow_mail?
      mm = MailMagazine.new

      if self.allow_mail
        mm.add_member(self, email)
      else
        # mm.remove_member(email) if mm.member?(email)
        mm.remove_member(email)
      end
    end
  # rescue => e
  end
end
