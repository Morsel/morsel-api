class AssociatedUserSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :username,
             :user_photo,
             :fullname

   def user_photo
  	object.user_photo_logo 
   end

  def fullname
   object.full_name	
  end
end
