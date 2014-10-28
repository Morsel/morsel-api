class SlimMorselWithNoteSerializer < SlimMorselSerializer
  def attributes
    hash = super
    if object.respond_to? :note
      hash['note'] = object.note
    end
    hash
  end
end
