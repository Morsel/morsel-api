class NotificationSerializer < ActiveModel::Serializer
  attributes :id,
             :message,
             :created_at,
             :payload_type

  has_one :payload
end
