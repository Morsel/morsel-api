class LikedItemSerializer < ItemSerializer
  include LikeableSerializerAttributes
  attributes  :creator,
              :morsel

  def creator
    {
      id:         object.creator.id,
      username:   object.creator.username,
      first_name: object.creator.first_name,
      last_name:  object.creator.last_name,
      created_at: object.creator.created_at,
      updated_at: object.creator.updated_at
    }
  end

  def morsel
    {
      id:         object.morsel.id,
      title:      object.morsel.title,
      slug:       object.morsel.cached_slug,
      created_at: object.morsel.created_at,
      updated_at: object.morsel.updated_at
    }
  end
end
