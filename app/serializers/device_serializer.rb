class DeviceSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :token,
             :model,
             :user_id,
             :created_at
end
