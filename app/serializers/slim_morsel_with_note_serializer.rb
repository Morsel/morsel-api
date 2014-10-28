class SlimMorselWithNoteSerializer < SlimMorselSerializer
  def attributes
    hash = super
    hash['note'] = object.note if object.respond_to? :note
    hash['sort_order'] = object.sort_order if object.respond_to? :sort_order
    hash
  end
end
