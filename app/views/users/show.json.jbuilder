json.partial! @user
json.like_count user.morsel_likes_for_my_morsels_by_others_count
json.morsel_count user.morsels.count

json.posts @user.posts do |post|
  json.partial! post
  json.morsels post.morsels do |morsel|
    json.partial! morsel, post: post
  end
end
