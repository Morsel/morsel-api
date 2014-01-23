json.(user,
  :id,
  :username,
  :first_name,
  :last_name,
  :sign_in_count,
  :created_at,
  :title,
  :twitter_username
)

json.photos do
  json._40x user.photo_url(:_40x)
  json._72x user.photo_url(:_72x)
  json._80x user.photo_url(:_80x)
  json._144x user.photo_url(:_144x)
end
