class SlimPlaceSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :address,
              :city,
              :state,
              :postal_code,
              :country,
              :created_at,
              :updated_at,
              :lat,
              :lon,
              :widget_url
end
