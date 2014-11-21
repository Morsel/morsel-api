class ActivitySerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :action_type,
             :subject_type,
             :message

  has_one :action
  has_one :subject
  has_one :creator, serializer: SlimUserSerializer
end
