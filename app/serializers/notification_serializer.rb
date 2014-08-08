class NotificationSerializer < ActiveModel::Serializer
  attributes :id,
             :message,
             :created_at,
             :marked_read_at,
             :payload_type

  has_one :payload
end
