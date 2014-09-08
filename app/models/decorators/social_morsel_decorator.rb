class SocialMorselDecorator < SimpleDelegator
  def facebook_message
    "\"#{title}\" #{facebook_mrsl} via Morsel".mrsl_normalize
  end

  def twitter_message
    "\"#{title}\" #{twitter_mrsl} via @#{Settings.morsel.twitter_username}"
  end
end
