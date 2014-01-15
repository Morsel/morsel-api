json.partial! post

json.creator post.creator, :id, :first_name, :last_name, :photo_url, :created_at

json.morsels post.morsels do |morsel|
  json.partial! morsel, post: post
end
