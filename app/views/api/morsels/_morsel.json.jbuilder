json.(morsel,
  :id,
  :description,
  :photo_url,
  :creator_id,
  :created_at
)

if defined?(post) && post.present?
  json.post_id post.id
  json.sort_order morsel.sort_order_for_post_id(post.id)
end

json.liked current_user.likes?(morsel) if defined?(current_user)
