class UpdateMorselTags
  include Service

  attribute :morsel, Morsel
  validates :morsel, presence: true

  def call
    if extract_hashtags_service.valid?
      remove_unused_tags
      create_new_tags

      Tag.includes(:keyword).where(taggable: morsel, keywords: { type: 'Hashtag' }).map(&:name).sort
    else
      errors.add(:base, 'unable to extract hashtags')
    end
  end

  private

  def extract_hashtags_service
    @extract_hashtags_service ||= ExtractHashtags.call(text: morsel.summary)
  end

  def existing_tags
    @existing_tags ||= Tag.includes(:keyword).where(taggable: morsel, keywords: { type: 'Hashtag' })
  end

  def downcased_extracted_keyword_names
    @downcased_extracted_keyword_names ||= extracted_keyword_names.map(&:downcase)
  end

  def extracted_keyword_names
    @extracted_keyword_names ||= extract_hashtags_service.response
  end

  def remove_unused_tags
    existing_tags.each do |tag|
      downcased_tag_name = tag.name.downcase
      if downcased_extracted_keyword_names.exclude? downcased_tag_name
        tag.destroy
        extracted_keyword_names.reject! { |k| k.downcase == downcased_tag_name }
      end
    end
  end

  def create_new_tags
    extracted_keyword_names.each do |extracted_keyword_name|
      keyword = Hashtag.find_by(Hashtag.arel_table[:name].lower.eq(extracted_keyword_name.downcase)) || Hashtag.create(name: extracted_keyword_name)
      Tag.find_or_create_by!(tagger: morsel.creator, keyword: keyword, taggable: morsel)
    end
  end
end
