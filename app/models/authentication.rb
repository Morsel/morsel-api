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
# **`token`**       | `string(255)`      |
# **`secret`**      | `string(255)`      |
# **`name`**        | `string(255)`      |
# **`link`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

class Authentication < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable, UserCreatable

  attr_accessor :short_lived

  belongs_to :user

  validates :provider,  allow_blank: false,
                        inclusion: %w(facebook twitter),
                        presence: true

  validates :secret, presence: true, if: proc { |a| a.twitter? }
  validates :token, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider, message: 'already exists' }
  validates :user, presence: true

  def exchange_access_token
    self.token = Koala::Facebook::OAuth.new(Settings.facebook.app_id, Settings.facebook.app_secret).exchange_access_token(token) if short_lived? && facebook?
  end

  def facebook?
    provider == 'facebook'
  end

  def twitter?
    provider == 'twitter'
  end

  private

  def short_lived?
    short_lived == 'true'
  end
end
