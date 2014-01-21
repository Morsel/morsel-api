class String
  def normalize
    ActiveSupport::Multibyte::Chars.new(self).normalize(:c).to_s
  end

  def twitter_string(url = nil)
    twitter_string = normalize

    twitter_max_tweet_length = 140

    if url.nil?
      max_message_length = twitter_max_tweet_length
    else
      twitter_url_max_length = 23 # NOTE: This may change
      max_message_length = twitter_max_tweet_length - twitter_url_max_length - 1
    end

    # truncate
    twitter_string = twitter_string.truncate( max_message_length,
                                              separator: ' ',
                                              omission: '... ') if twitter_string.length > max_message_length

    twitter_string << url if url.present?

    twitter_string
  end
end
