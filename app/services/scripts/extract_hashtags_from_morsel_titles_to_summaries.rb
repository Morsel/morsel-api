module Scripts
  class ExtractHashtagsFromMorselTitlesToSummaries
    include Service

    def call
      Morsel.where(Morsel.arel_table[:title].matches('%#%')).find_each do |morsel|
        title = morsel.title.dup
        ExtractHashtags.call(text: title).response.each do |hashtag|
          formatted_hashtag = "##{hashtag}"
          morsel.summary = (morsel.summary || "") + " #{formatted_hashtag}"
          morsel.summary.strip!

          title.slice!(formatted_hashtag) unless title == formatted_hashtag
        end

        morsel.title = title.strip.squeeze(' ')
        morsel.save!
      end
    end
  end
end
