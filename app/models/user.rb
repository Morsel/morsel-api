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
# **`title`**                   | `string(255)`      |
# **`provider`**                | `string(255)`      |
# **`uid`**                     | `string(255)`      |
# **`username`**                | `string(255)`      |
# **`bio`**                     | `string(255)`      |
# **`active`**                  | `boolean`          | `default(TRUE)`
# **`verified_at`**             | `datetime`         |
# **`type`**                    | `string(255)`      | `default("User")`
# **`unsubscribed`**            | `boolean`          | `default(FALSE)`
#

class User < ActiveRecord::Base
  include Authority::UserAbilities
  include PhotoUploadable
  rolify

  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable
  # :recoverable

  before_save :ensure_authentication_token
  after_save :ensure_role

  has_many :authorizations
  has_many :comments, through: :morsels
  has_many  :facebook_authorizations,
            -> { where provider: 'facebook' },
            class_name: 'Authorization',
            foreign_key: :user_id
  has_many  :twitter_authorizations,
            -> { where provider: 'twitter' },
            class_name: 'Authorization',
            foreign_key: :user_id
  has_many :liked_morsels, source: :morsel, through: :likes
  has_many :likes
  has_many :morsels, foreign_key: :creator_id
  has_many :posts, foreign_key: :creator_id

  scope :chefs, -> { where(industry: 'chef') }
  scope :writers, -> { where(industry: 'writer') }
  scope :diners, -> { where(industry: 'diner') }

  validates :username,
            format: { with: /\A[a-zA-Z][A-Za-z0-9_]+$\z/ },
            length: { maximum: 15 },
            presence: true,
            uniqueness: { case_sensitive: false },
            exclusion: ReservedPaths.non_username_paths

  mount_uploader :photo, UserPhotoUploader

  def self.find_by_id_or_username(id_or_username)
    if id_or_username.to_i > 0
      find_by(id: id_or_username)
    else
      find_by('lower(username) = lower(?)', id_or_username)
    end
  end

  def morsel_likes_for_my_morsels_by_others_count
    Like.where(morsel_id: morsel_ids).count
  end

  def likes?(morsel)
    liked_morsels.include?(morsel)
  end

  def facebook_authorization
    facebook_authorizations.first
  end

  def authorized_with_facebook?
    facebook_authorization && facebook_authorization.token.present?
  end

  def post_to_facebook(message)
    SocialWorker.perform_async(:facebook, id, message) if authorized_with_facebook?
  end

  def facebook_uid
    facebook_authorization.uid if authorized_with_facebook?
  end

  def twitter_authorization
    twitter_authorizations.first
  end

  def authorized_with_twitter?
    twitter_authorization && twitter_authorization.token.present?
  end

  def post_to_twitter(message)
    SocialWorker.perform_async(:twitter, id, message) if authorized_with_twitter?
  end

  def twitter_username
    twitter_authorization.name if authorized_with_twitter?
  end

  def photos_hash
    if photo_url.present?
      {
        _40x40: photo_url(:_40x40),
        _72x72: photo_url(:_72x72),
        _80x80: photo_url(:_80x80),
        _144x144: photo_url(:_144x144)
      }
    end
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

  def send_reserved_username_email
    EmailWorker.perform_async(id) unless unsubscribed?
  end

  private

  def ensure_authentication_token
    self.authentication_token = generate_authentication_token if authentication_token.blank?
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
    when 'writer'
      add_role(:media)
    end

    if admin
      add_role(:admin)
    else
      remove_role(:admin)
    end
  end
end
