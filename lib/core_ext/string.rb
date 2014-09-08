class String
  def mrsl_normalize
    ActiveSupport::Multibyte::Chars.new(self).normalize(:c).to_s
  end

  def mrsl_twitter_string(suffix_string)
    twitter_string = mrsl_normalize

    twitter_max_tweet_length = 140

    max_message_length = twitter_max_tweet_length - suffix_string.length - 1
    twitter_string = twitter_string.truncate(max_message_length,
                                             separator: ' ',
                                             omission: '...') if twitter_string.length > max_message_length

    "#{twitter_string} #{suffix_string}"
  end
end
