class ItemForFeedSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :created_at,
             :updated_at,
             :nonce,
             :photos,
             :photo_processing,
             :in_progression,
             :liked,
             :creator,
             :sort_order,
             :morsel

  def photos
    object.photos_hash
  end

  def in_progression
    if object.morsel
      object.morsel.items.count > 1
    else
      false
    end
  end

  def liked
    current_user.present? && current_user.likes?(object)
  end

  def creator
    user = object.creator
    {
      id: user.id,
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name,
      photos: user.photos_hash
    }
  end

  def morsel
    morsel = object.morsel
    if morsel
      {
        id: morsel.id,
        title: morsel.title,
        slug: morsel.cached_slug,
        created_at: morsel.created_at
      }
    else
      nil
    end
  end
end
