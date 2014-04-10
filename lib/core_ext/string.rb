class String
  def normalize
    ActiveSupport::Multibyte::Chars.new(self).normalize(:c).to_s
  end

  def twitter_string(url)
    twitter_string = normalize

    twitter_max_tweet_length = 140

    twitter_url_max_length = 23 # NOTE: This may change
    max_message_length = twitter_max_tweet_length - twitter_url_max_length - 1
    twitter_string = twitter_string.truncate(max_message_length,
                                             separator: ' ',
                                             omission: '...') if twitter_string.length > max_message_length

    "#{twitter_string} #{url}"
  end
end
