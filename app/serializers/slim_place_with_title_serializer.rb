class SlimPlaceWithTitleSerializer < SlimPlaceSerializer
  def attributes
    hash = super
    hash['title'] = object.title if object.respond_to? :title
    hash
  end
end
