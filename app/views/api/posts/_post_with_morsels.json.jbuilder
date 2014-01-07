json.partial! post
json.morsels post.morsels do |json_morsel, morsel|
  json.partial! morsel
end
