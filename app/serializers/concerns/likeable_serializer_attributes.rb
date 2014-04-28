module LikeableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :liked_at
  end

  def liked_at
    Like.find_by(liker_id: options[:context][:liker_id], likeable_id: object.id, likeable_type: object.class.to_s).created_at
  end
end
