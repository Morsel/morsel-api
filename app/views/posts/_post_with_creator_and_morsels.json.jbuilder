json.partial! post

json.creator do
  if post.creator.present?
    json.partial! 'users/user', user: post.creator
  end
end


json.morsels post.morsels do |morsel|
  json.partial! morsel, post: post
end
