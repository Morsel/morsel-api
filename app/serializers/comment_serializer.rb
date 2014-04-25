class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :created_at,
             :commentable_id,
             :commentable_type,
             :creator

  def creator
    user = object.user
    {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      username: user.username,
      photos: user.photos_hash
    }
  end
end
