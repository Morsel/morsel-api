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
#

class User < ActiveRecord::Base
  rolify

  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable
  # :recoverable

  before_save :ensure_authentication_token
  before_save :update_photo_attributes

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

  validates :username,
            format: { with: /\A[A-Za-z0-9_]+$\z/ },
            length: { maximum: 15 },
            presence: true,
            uniqueness: { case_sensitive: false }

  include PhotoUploadable

  mount_uploader :photo, UserPhotoUploader

  def can_delete_comment?(comment)
    comment.user == self || comment.morsel.creator == self
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
    facebook_authorizations.present?
  end

  def post_to_facebook(message)
    if facebook_client.present?
      facebook_client.put_connections('me', 'feed', message: message)
    else
      nil
    end
  end

  def twitter_authorization
    twitter_authorizations.first
  end

  def authorized_with_twitter?
    twitter_authorization.present?
  end

  def post_to_twitter(message)
    if twitter_client.present?
      twitter_client.update(message)
    else
      nil
      # TODO: throw an error
    end
  end

  def twitter_username
    twitter_authorization.name if authorized_with_twitter?
  end

  private

  def ensure_authentication_token
    self.authentication_token = generate_authentication_token if authentication_token.blank?
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def update_photo_attributes
    if photo.present? && photo_changed?
      self.photo_content_type = photo.file.content_type
      self.photo_file_size = photo.file.size
      self.photo_updated_at = Time.now
    end
  end

  def facebook_client
    if authorized_with_facebook? && facebook_authorization.token.present?
      Koala::Facebook::API.new(facebook_authorization.token)
    else
      nil
    end
  end

  def twitter_client
    if authorized_with_twitter? && twitter_authorization.token.present?
      Twitter::REST::Client.new do |config|
        config.consumer_key = Settings.twitter.consumer_key
        config.consumer_secret = Settings.twitter.consumer_secret
        config.access_token = twitter_authorization.token
        config.access_token_secret = twitter_authorization.secret
      end
    else
      nil
    end
  end
end
