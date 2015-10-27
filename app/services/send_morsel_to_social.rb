class SendMorselToSocial
  include Service

  attribute :morsel, Morsel
  attribute :user_id
  attribute :provider, String

  validates :morsel, presence: true
  validates :user_id, presence: true
  validates :provider, presence: true
  validate :morsel_photo_exists?

  def call
    if facebook?
      debugger
      authenticated_user.post_facebook_photo_url(morsel.photo_url, social_message)
    elsif twitter?
      authenticated_user.post_twitter_photo_url(morsel.photo_url, social_message)
    end
  end

  private

  def morsel_photo_exists?
    errors.add(:photo, 'is required') if morsel.photo_url.blank?
  end

  def authenticated_user
    if facebook?
      FacebookAuthenticatedUserDecorator.new(User.includes(:facebook_authentications).find(user_id))
    elsif twitter?
      TwitterAuthenticatedUserDecorator.new(User.includes(:twitter_authentications).find(user_id))
    end
  end

  def social_message
    if facebook?
      SocialMorselDecorator.new(morsel).facebook_message
    elsif twitter?
      SocialMorselDecorator.new(morsel).twitter_message
    end
  end

  def facebook?
    provider == 'facebook'
  end

  def twitter?
    provider == 'twitter'
  end
end
