class ExtractHashtags
  include Service

  attribute :text, String
  validates :text, presence: true

  def call
    Twitter::Extractor.extract_hashtags(text).uniq.sort
  end
end
