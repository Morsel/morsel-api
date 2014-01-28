json.partial! post

json.creator do
  if post.creator.present?
    json.partial! 'users/user', user: post.creator
  end
end


if defined?(include_drafts) && include_drafts
  json.morsels post.morsels do |morsel|
    json.partial! morsel, post: post
  end
else
  json.morsels post.morsels.published do |morsel|
    json.partial! morsel, post: post
  end
end
