class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :created_at,
             :commentable_id,
             :commentable_type

  has_one :creator, serializer: SlimUserSerializer
end
