module FollowableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :followed_at
  end

  def followed_at
    Follow.find_by(follower_id: options[:context][:follower_id], followable_id: object.id, followable_type: object.class.to_s).created_at
  end
end
