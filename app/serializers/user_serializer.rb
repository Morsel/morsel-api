class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name,
             :created_at,
             :title,
             :bio,
             :photos

  def photos
    object.photos_hash
  end
end
