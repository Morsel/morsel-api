class FeedItemSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :updated_at,
             :subject_type,
             :featured,
             :user_id

  has_one :subject
end
