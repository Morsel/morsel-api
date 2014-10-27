# ## Schema Information
#
# Table name: `authentications`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`provider`**    | `string(255)`      |
# **`uid`**         | `string(255)`      |
# **`user_id`**     | `integer`          |
# **`token`**       | `text`             |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#

class Authentication < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable, UserCreatable
  acts_as_paranoid

  attr_accessor :short_lived

  belongs_to :user

  self.authorizer_name = 'AuthenticationAuthorizer'

  validates :provider,  allow_blank: false,
                        inclusion: %w(facebook instagram twitter),
                        presence: true

  validates :secret, presence: true, if: proc { |a| a.twitter? }
  validates :token, presence: true
  validates :uid, presence: true,
                  uniqueness: {
                    scope: :provider,
                    message: 'already exists',
                    conditions: -> { where(deleted_at: nil) }
                  }
  validates :user, presence: true

  concerning :AutoFollow do
    included do
      after_commit :fetch_and_follow_social_connections, on: :create
      attr_accessor :auto_follow
    end

    private

    def auto_follow?
      Settings.flags.enable_auto_follow && ActiveRecord::ConnectionAdapters::Column.value_to_boolean(auto_follow)
    end

    def fetch_and_follow_social_connections
      FetchAndFollowSocialUidsWorker.perform_async(
        authentication_id: id
      ) if auto_follow?
    end
  end

  def exchange_access_token
    self.token = Koala::Facebook::OAuth.new(Settings.facebook.app_id, Settings.facebook.app_secret).exchange_access_token(token) if short_lived? && facebook?
  end

  def facebook?
    provider == 'facebook'
  end

  def instagram?
    provider == 'instagram'
  end

  def twitter?
    provider == 'twitter'
  end

  private

  def short_lived?
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(short_lived)
  end
end
