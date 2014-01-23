json.partial! post

json.creator do
  json.partial! 'api/users/user', user: post.creator
end


json.morsels post.morsels do |morsel|
  json.partial! morsel, post: post
end
