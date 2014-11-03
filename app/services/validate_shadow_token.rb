class ValidateShadowToken
  include Service

  attribute :shadow_token, String
  attribute :user, User

  validates :shadow_token, presence: true
  validates :user, presence: true

  validate :valid_shadow_token?

  def call
    true
  end

  private

  def valid_shadow_token?
    redis = Redis.new url: Settings.redis.url
    errors.add(:shadow_token, 'is invalid') unless shadow_token == redis.get(redis_key)
  end

  def redis_key
    "user_shadow_token/#{user.id}" if user
  end
end
