class AssociationRequestSerializer < ActiveModel::Serializer
  attributes :id,
             :is_approved,
             :associated_user,
             :host_user

  def associated_user
    AssociatedUserSerializer.new(object.associated_user).attributes
  end

  def host_user
    AssociatedUserSerializer.new(object.host).attributes
  end

  def is_approved
  	object.approved ? "true" :	"false"
  end

end
