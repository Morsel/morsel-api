class SocialMorselDecorator < SimpleDelegator
  def facebook_message
    "\"#{title}\" #{facebook_mrsl} via Morsel #{hashtags_with_hashes}".mrsl_normalize
  end

  def twitter_message
    "#{base_twitter_message} #{hashtags_with_hashes(tweet_size)}"
  end

  private

  def base_twitter_message
    "\"#{title}\" #{twitter_mrsl} via @#{Settings.morsel.twitter_username}"
  end

  def hashtags_with_hashes(char_limit=0)
    hashtags = []
    if char_limit > 0
      character_count = 0
      keywords.where(type: 'Hashtag').each do |hashtag|
        character_count += (hashtag.name.size + 2)
        break if character_count > char_limit
        hashed_hashtag = "##{hashtag.name}"
        hashtags << hashed_hashtag unless title.include? hashed_hashtag
      end
    else
      hashtags = keywords.where(type: 'Hashtag').map { |hashtag| "##{hashtag.name}" }
    end

    hashtags.join ' '
  end

  def tweet_size
    140 - base_twitter_message.length - 1
  end
end
