class SlimPlaceSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :slug,
             :address,
             :city,
             :state,
             :country,
             :created_at,
             :updated_at
end
