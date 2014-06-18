class SlimUserSerializer < ActiveModel::Serializer
  include PhotoUploadableSerializerAttributes

  attributes :id,
             :username,
             :first_name,
             :last_name,
             :bio,
             :industry,
             :professional

  def attributes
    hash = super
    hash['title'] = object.title if object.respond_to? :title
    hash
  end
end
