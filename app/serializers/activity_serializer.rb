class ActivitySerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :action_type,
             :subject_type

  has_one :action
  has_one :subject
  has_one :creator
end
