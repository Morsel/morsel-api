json.partial! post

json.creator post.creator, :id, :username, :first_name, :last_name, :photo_url, :twitter_username, :created_at

json.morsels post.morsels do |morsel|
  json.partial! morsel, post: post
end
