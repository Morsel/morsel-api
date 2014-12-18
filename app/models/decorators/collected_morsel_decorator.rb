class CollectedMorselDecorator < SimpleDelegator
  attr_accessor :note
  attr_accessor :sort_order

  def update_with_collection_morsel(collection_morsel)
    self.note = collection_morsel.note
    self.sort_order = collection_morsel.sort_order
  end
end
