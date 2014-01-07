json.partial! @user

json.posts @user.posts do |json_post, post|
  json.partial! post
  json.morsels post.morsels do |json_morsel, morsel|
    json.partial! morsel
  end
end
