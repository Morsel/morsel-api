class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :created_at,
             :creator_id,
             :morsel_id

  def creator_id
    object.user.id
  end

  def morsel_id
    object.morsel.id
  end
end
