class SlimPlaceWithTitleSerializer < SlimPlaceSerializer
  attributes :title

  def title
    options[:context][:title]
  end
end
