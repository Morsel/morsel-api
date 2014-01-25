json.(morsel,
  :id,
  :description,
  :creator_id,
  :created_at
)

if morsel.photo_url.present?
  json.photos do
    json._104x104 morsel.photo_url(:_104x104)
    json._208x208 morsel.photo_url(:_208x208)
    json._320x214 morsel.photo_url(:_320x214)
    json._640x428 morsel.photo_url(:_640x428)
    json._640x640 morsel.photo_url(:_640x640)
  end
else
  json.photos nil
end

if defined?(post) && post.present?
  json.post_id post.id
  json.sort_order morsel.sort_order_for_post_id(post.id)
end

json.liked current_user.likes?(morsel) if defined?(current_user)

if defined?(tweet) && tweet.present?
  json.tweet_url tweet.url.to_s
end

if defined?(fb_post) && fb_post.present?
  json.fb_post_url "https://facebook.com/#{fb_post['id']}"
end

json.comments morsel.comments do |comment|
  json.partial! comment
end
