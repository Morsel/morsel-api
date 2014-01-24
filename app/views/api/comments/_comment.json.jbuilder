json.(comment,
  :id,
  :description,
  :created_at
)

json.creator_id comment.user.id
json.morsel_id comment.morsel.id
