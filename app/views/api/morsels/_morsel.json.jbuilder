json.(morsel,
  :id,
  :description,
  :photo_url,
  :creator_id,
  :created_at
)

json.liked current_user.likes?(morsel) if current_user
