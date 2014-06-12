class ItemSansMorselSerializer < ItemSerializer
  def filter(keys)
    keys.delete :morsel
  end
end
