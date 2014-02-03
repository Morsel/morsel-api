json.(user,
  :id,
  :username,
  :first_name,
  :last_name,
  :sign_in_count,
  :created_at,
  :title,
  :twitter_username,
  :bio
)

if user.photo_url.present?
  json.photos do
    json._40x40 user.photo_url(:_40x40)
    json._72x72 user.photo_url(:_72x72)
    json._80x80 user.photo_url(:_80x80)
    json._144x144 user.photo_url(:_144x144)
  end
else
  json.photos nil
end

if user == current_user
  json.draft_count user.morsels.drafts.count
end
