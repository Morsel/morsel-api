class SlimUserSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :username,
             :first_name,
             :last_name
end
