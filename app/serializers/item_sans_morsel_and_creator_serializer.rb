class ItemSansMorselAndCreatorSerializer < ItemSerializer
  def include_creator?; true end # DEPRECATED, Remove: creator (https://app.asana.com/0/19486350215520/19486350215546). Set to false
  def include_morsel?; true end # DEPRECATED, Remove: morsel (https://app.asana.com/0/19486350215520/19486350215548). Set to false
end
