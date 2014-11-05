# DEPRECATED, Remove: liked (https://app.asana.com/0/19486350215520/19486350215550)
class LikedItemSerializer < ItemSerializer
  include LikeableSerializerAttributes

  has_one :creator, serializer: SlimUserSerializer
  has_one :morsel, serializer: SlimMorselSerializer
end
