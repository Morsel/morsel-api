class LikedItemSerializer < ItemSerializer
  has_one :creator
  has_one :morsel
end
