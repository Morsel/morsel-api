class AuthenticationSerializer < ActiveModel::Serializer
  attributes :id,
             :provider,
             :uid,
             :user_id,
             :token,
             :secret,
             :name,
             :link
end
