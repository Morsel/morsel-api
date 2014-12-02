class KeywordSerializer < ActiveModel::Serializer
  attributes :id,
             :type,
             :name,
             :tags_count
end
