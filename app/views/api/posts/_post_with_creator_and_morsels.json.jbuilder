json.partial! post

json.creator post.creator, :id, :first_name, :last_name, :profile_url, :created_at

json.morsels post.morsels do |morsel|
  json.partial! morsel
end