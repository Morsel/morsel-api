class GenerateShadowToken
  include Service

  attribute :user, User
  validates :user, presence: true

  def call
    generate_shadow_token
  end

  private

  def generate_shadow_token
    redis = Redis.new url: ENV['OPENREDIS_URL']
    token = SecureRandom.uuid.gsub('-', '')
    redis.setex redis_key, 60, token
    token
  end

  def redis_key
    "user_shadow_token/#{user.id}"
  end
end
