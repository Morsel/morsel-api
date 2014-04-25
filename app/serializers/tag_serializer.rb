class TagSerializer < ActiveModel::Serializer
  attributes :id,
             :taggable_id,
             :taggable_type,
             :created_at,
             :updated_at

  has_one :keyword, serializer: KeywordSerializer
end
