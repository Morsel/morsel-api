module FollowableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :followed_at
  end

  def followed_at
    if options[:context][:follower_id]
      Follow.find_by(follower_id: options[:context][:follower_id], followable_id: object.id, followable_type: object.class.to_s).created_at
    elsif options[:context][:followable_id]
      Follow.find_by(follower_id: object.id, followable_id: options[:context][:followable_id], followable_type: object.class.to_s).created_at
    end
  end
end
