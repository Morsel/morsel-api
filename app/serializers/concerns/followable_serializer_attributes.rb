module FollowableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :followed_at
  end

  def followed_at
    if follower_id
      Follow.find_by(follower_id: follower_id, followable_id: object.id, followable_type: followable_type).created_at
    elsif followable_id
      Follow.find_by(follower_id: object.id, followable_id: followable_id, followable_type: followable_type).created_at
    end
  end

  private

  def followable_id
    options[:context][:followable_id] if options[:context]
  end

  def followable_type
    options[:context][:followable_type] if options[:context]
  end

  def follower_id
    options[:context][:follower_id] if options[:context]
  end
end
