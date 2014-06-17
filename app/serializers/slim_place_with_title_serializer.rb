class SlimPlaceWithTitleSerializer < SlimPlaceSerializer
  def attributes
    hash = super
    if object.respond_to? :title
      hash['title'] = object.title
    elsif options[:context][:title]
      hash['title'] = options[:context][:title]
    end
    hash
  end
end
