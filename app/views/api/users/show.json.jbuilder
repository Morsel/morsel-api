json.partial! @user

json.posts @user.posts do |post|
  json.partial! post
  json.morsels post.morsels do |morsel|
    json.partial! morsel, post: post
  end
end
