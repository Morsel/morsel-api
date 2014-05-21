# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `integer`          | `not null, primary key`
# **`email`**                   | `string(255)`      | `default(""), not null`
# **`encrypted_password`**      | `string(255)`      | `default(""), not null`
# **`reset_password_token`**    | `string(255)`      |
# **`reset_password_sent_at`**  | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`sign_in_count`**           | `integer`          | `default(0), not null`
# **`current_sign_in_at`**      | `datetime`         |
# **`last_sign_in_at`**         | `datetime`         |
# **`current_sign_in_ip`**      | `string(255)`      |
# **`last_sign_in_ip`**         | `string(255)`      |
# **`created_at`**              | `datetime`         |
# **`updated_at`**              | `datetime`         |
# **`first_name`**              | `string(255)`      |
# **`last_name`**               | `string(255)`      |
# **`admin`**                   | `boolean`          | `default(FALSE), not null`
# **`authentication_token`**    | `string(255)`      |
# **`photo`**                   | `string(255)`      |
# **`photo_content_type`**      | `string(255)`      |
# **`photo_file_size`**         | `string(255)`      |
# **`photo_updated_at`**        | `datetime`         |
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`industry`**                | `string(255)`      |
# **`unsubscribed`**            | `boolean`          | `default(FALSE)`
# **`photo_processing`**        | `boolean`          |
# **`staff`**                   | `boolean`          | `default(FALSE)`
# **`deleted_at`**              | `datetime`         |
# **`promoted`**                | `boolean`          | `default(FALSE)`
#

class User < ActiveRecord::Base
  include Authority::UserAbilities, Authority::Abilities, Followable, PhotoUploadable, Taggable, TimelinePaginateable
  acts_as_paranoid
  rolify

  self.authorizer_name = 'UserAuthorizer'
  def self.allowed_keyword_types; %w(Cuisine Specialty) end

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

  before_validation :ensure_authentication_token
  before_save :process_remote_photo_url
  after_save :ensure_role

  has_many :authentications, inverse_of: :user

  has_many :comments, through: :items
  has_many  :facebook_authentications,
            -> { where provider: 'facebook' },
            class_name: 'Authentication',
            foreign_key: :user_id
  has_many  :instagram_authentications,
            -> { where provider: 'instagram' },
            class_name: 'Authentication',
            foreign_key: :user_id
  has_many  :twitter_authentications,
            -> { where provider: 'twitter' },
            class_name: 'Authentication',
            foreign_key: :user_id

  has_many :likes, foreign_key: :liker_id
  has_many :liked_items, through: :likes, source: :likeable, source_type: 'Item'

  has_many :followable_follows, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followed_users, through: :followable_follows, source: :followable, source_type: 'User'
  has_many :followed_keywords, through: :followable_follows, source: :followable, source_type: 'Keyword'

  has_many :items, foreign_key: :creator_id
  has_many :morsels, foreign_key: :creator_id
  has_many :activities, foreign_key: :creator_id
  has_many :notifications

  validates :industry,
            inclusion: {
              in: %w(chef media diner),
              message: '%{value} is not a valid industry'
            },
            allow_nil: true

  validate :validate_email
  validate :validate_username
  validate :validate_password

  mount_uploader :photo, UserPhotoUploader
  process_in_background :photo

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def login
    username || email
  end

  def liked_items_count
    liked_items.count
  end

  def likes_item?(item)
    liked_items.include?(item)
  end

  def morsel_count
    morsels.published.count
  end

  def follower_count
    followers.count
  end

  def followed_user_count
    followed_users.count
  end

  def following_user?(user)
    followed_users.include?(user)
  end

  def full_name
    if first_name && last_name
      "#{first_name} #{last_name}"
    elsif first_name
      "#{first_name}"
    elsif last_name
      "#{last_name}"
    end
  end

  def validate_email
    if email.nil?
      errors.add(:email, 'is required')
    else
      errors.add(:email, 'is invalid') unless email.match(/\A[^@]+@([^@\.]+\.)+[^@\.]+\z/)
      errors.add(:email, 'has already been taken') if User.where('lower(email) = ? AND id != ?', email.downcase, id || 0).count > 0
    end
  end

  def validate_username
    if username.nil?
      errors.add(:username, 'is required')
    else
      errors.add(:username, 'must be less than 16 characters') if username.length > 15
      errors.add(:username, 'cannot contain spaces') if username.include? ' '
      errors.add(:username, 'has already been taken') if ReservedPaths.non_username_paths.include?(username)
      errors.add(:username, 'must start with a letter and can only contain alphanumeric characters and underscores') unless username.match(/\A[a-zA-Z][A-Za-z0-9_]+$\z/)
      errors.add(:username, 'has already been taken') if User.where('lower(username) = ? AND id != ?', username.downcase, id || 0).count > 0
    end
  end

  def validate_password
    if !persisted? && password.blank?
      errors.add(:password, 'is required')
    elsif password.present?
      if password.length < 8
        errors.add(:password, 'must be at least 8 characters')
      elsif password.length >= 128
        errors.add(:password, 'must be less than 128 characters')
      end
    end
  end

  private

  def ensure_authentication_token
    # If the User is new or they are changing their password, regenerate authentication_token
    self.authentication_token = generate_authentication_token if authentication_token.blank? || password.present?
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end

  def ensure_role
    case industry
    when 'chef'
      add_role(:chef)
    when 'media'
      add_role(:media)
    end

    if admin
      add_role(:admin)
    else
      remove_role(:admin)
    end

    if staff
      add_role(:staff)
    else
      remove_role(:staff)
    end
  end

  def process_remote_photo_url
    if remote_photo_url && photo_changed?
      self.process_photo_upload = true
      self.remote_photo_url = remote_photo_url
    end
  end
end
