# ## Schema Information
#
# Table name: `authorizations`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`provider`**    | `string(255)`      |
# **`uid`**         | `string(255)`      |
# **`user_id`**     | `integer`          |
# **`token`**       | `string(255)`      |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Authorization < ActiveRecord::Base
  belongs_to :user

  validates :provider, inclusion: %w(twitter), allow_blank: false, presence: true
  validates :token, presence: true
  validates :uid, uniqueness: { scope: :provider }, presence: true
  validates :user, presence: true
  validates_associated :user

  def self.build_authorization(provider, user, token, secret)
    authorization = user.authorizations.build(provider: provider,
                                              token: token,
                                              secret: secret,
                                              user_id: user.id)

    if provider == 'twitter'
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key = Settings.twitter.consumer_key
        config.consumer_secret = Settings.twitter.consumer_secret
        config.access_token = authorization.token
        config.access_token_secret = authorization.secret
      end

      if twitter_client.current_user.present?
        authorization.uid = twitter_client.current_user.id
        authorization.name = twitter_client.current_user.screen_name
        authorization.link = twitter_client.current_user.url.to_s
        user.save
      else
        authorization.errors.add(:token, 'is not valid') if authorization.uid.blank?
      end
    end

    authorization
  end
end
