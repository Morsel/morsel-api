class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name,
             :sign_in_count,
             :created_at,
             :title,
             :twitter_username,
             :facebook_uid,
             :bio,
             :photos

  def attributes
    data = super
    data[:draft_count] = object.morsels.drafts.count if current_user == object
    data
  end

  def photos
    if object.photo_url.present?
      {
        _40x40: object.photo_url(:_40x40),
        _72x72: object.photo_url(:_72x72),
        _80x80: object.photo_url(:_80x80),
        _144x144: object.photo_url(:_144x144)
      }
    else
      nil
    end
  end
end
