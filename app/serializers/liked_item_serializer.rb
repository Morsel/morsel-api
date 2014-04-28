class LikedItemSerializer < ItemSerializer
  include LikeableSerializerAttributes

  has_one :creator
  has_one :morsel
end
