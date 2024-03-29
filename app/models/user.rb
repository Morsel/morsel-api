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
# **`photo_processing`**        | `boolean`          |
# **`staff`**                   | `boolean`          | `default(FALSE)`
# **`deleted_at`**              | `datetime`         |
# **`promoted`**                | `boolean`          | `default(FALSE)`
# **`settings`**                | `hstore`           | `default({})`
# **`professional`**            | `boolean`          | `default(FALSE)`
# **`password_set`**            | `boolean`          | `default(TRUE)`
# **`drafts_count`**            | `integer`          | `default(0), not null`
# **`followed_users_count`**    | `integer`          | `default(0), not null`
# **`followers_count`**         | `integer`          | `default(0), not null`
#

class User < ActiveRecord::Base
  include Authority::UserAbilities,
          Authority::Abilities,
          Followable,
          PhotoUploadable,
          Taggable,
          TimelinePaginateable

  acts_as_paranoid
  has_paper_trail ignore: [:sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]
  rolify

  self.authorizer_name = 'UserAuthorizer'
  def self.allowed_keyword_types; %w(Cuisine Specialty) end

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

  before_validation :ensure_authentication_token
  after_validation :ensure_professional
  before_save :default_values
  after_commit :create_subscription_for_self, on: :create
  after_destroy :remove_subscription_for_self

  alias_attribute :draft_count, :drafts_count
  alias_attribute :followed_user_count, :followed_users_count

  has_many :authentications, inverse_of: :user

  has_many :comments, through: :items
  has_many :facebook_authentications, -> { where provider: 'facebook' },
           class_name: 'Authentication',
           foreign_key: :user_id
  has_many :instagram_authentications, -> { where provider: 'instagram' },
           class_name: 'Authentication',
           foreign_key: :user_id
  has_many :twitter_authentications, -> { where provider: 'twitter' },
           class_name: 'Authentication',
           foreign_key: :user_id

  has_many :likes, foreign_key: :liker_id
  has_many :liked_items, through: :likes, source: :likeable, source_type: 'Item'
  has_many :liked_morsels, through: :likes, source: :likeable, source_type: 'Morsel'

  has_many :followable_follows, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followed_users, through: :followable_follows, source: :followable, source_type: 'User'
  has_many :followed_places, through: :followable_follows, source: :followable, source_type: 'Place'
  has_many :followed_keywords, through: :followable_follows, source: :followable, source_type: 'Keyword'

  has_many :collections, inverse_of: :user
  has_many :items, foreign_key: :creator_id
  has_many :morsels, foreign_key: :creator_id
  has_many :activities, foreign_key: :creator_id
  has_many :activity_subscriptions, foreign_key: :subscriber_id
  has_many :notifications
  has_many :remote_notifications

  has_many :employments, inverse_of: :user
  has_many :places, through: :employments

  has_many :morsel_user_tags, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :promoted, -> { where(promoted: true) }
  scope :suggested, -> { promoted }
  scope :professional, -> { where(professional: true) }

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

  concerning :Devices do
    included do
      has_many :devices, dependent: :destroy
    end
  end

  concerning :UserSettings do
    included do
      store_accessor :settings, :unsubscribed, :auto_follow
    end

    def auto_follow?; ActiveRecord::ConnectionAdapters::Column.value_to_boolean(auto_follow) end

    def unsubscribed?; ActiveRecord::ConnectionAdapters::Column.value_to_boolean(unsubscribed) end
  end

  concerning :DeviseOverrides do
    included do
      attr_accessor :login
    end

    def after_password_reset
      update_attributes password_set: true
    end

    def login
      @login || username || email
    end

    def mrsl_send_reserved_username_instructions_notification(token)
      send_devise_notification(:reserved_username_instructions, token, {})
    end

    def mrsl_send_reserved_username_reminder_notification(token)
      send_devise_notification(:reserved_username_reminder, token, {})
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)

    if login
      login.downcase!
      where(conditions).where(
        User.arel_table[:username].lower.eq(login)
        .or(User.arel_table[:email].lower.eq(login))
      ).first
    else
      where(conditions).first
    end
  end

  def self.find_by_id_or_username(id_or_username)
    return if id_or_username.nil?

    if (id_or_username.to_s =~ /\A[-+]?\d*\.?\d+\z/).nil?
      find_by User.arel_table[:username].lower.eq(id_or_username.downcase)
    else
      find id_or_username
    end
  end

  def likes_item?(item)
    liked_items.include?(item)
  end

  def likes_morsel?(morsel)
    liked_morsels.include?(morsel)
  end

  def following_user?(user)
    followed_users.include?(user)
  end

  def following_place?(place)
    followed_places.include?(place)
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

  def full_name_with_username
    if full_name
      "#{full_name} (#{username})"
    else
      "(#{username})"
    end
  end

  def url
    # https://eatmorsel.com/marty
    "#{Settings.morsel.web_url}/#{username}"
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
      errors.add(:username, 'must start with a letter and can only contain alphanumeric characters and underscores') unless username.match(/\A[a-zA-Z]([A-Za-z0-9_]*)$\z/)
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

  def default_values
    self.auto_follow ||= true
  end

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

  def ensure_professional
    self.professional = industry == 'chef' if professional.nil? && industry.present?
  end

  def create_subscription_for_self
    SubscribeToSubjectActivityWorker.perform_async(
      subject_id: id,
      subject_type: 'User',
      subscriber_id: id,
      active: true,
      reason: 'created',
      actions: %w(follow)
    )
  end

  def remove_subscription_for_self
    UnsubscribeFromSubjectActivityWorker.perform_async(
      subject_id: id,
      subject_type: 'User',
      subscriber_id: id,
      reason: 'created',
      actions: %w(follow)
    )
  end
end
