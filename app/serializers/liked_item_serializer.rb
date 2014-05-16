class LikedItemSerializer < ItemSerializer
  include LikeableSerializerAttributes

  has_one :creator, serializer: SlimUserSerializer
  has_one :morsel, serializer: SlimMorselSerializer
end
