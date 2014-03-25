class FeedItemSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :updated_at,
             :subject_type

  has_one :subject
end
