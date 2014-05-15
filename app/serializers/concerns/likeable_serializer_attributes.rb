module LikeableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :liked_at
  end

  def liked_at
    Like.find_by(liker_id: liker_id, likeable_id: object.id, likeable_type: likeable_type).created_at
  end

  private

  def likeable_type
    options[:context][:likeable_type]
  end

  def liker_id
    options[:context][:liker_id]
  end
end
