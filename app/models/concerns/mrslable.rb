module Mrslable
  extend ActiveSupport::Concern

  def self.mrsl_mediums
    %i(
      facebook_mrsl
      twitter_mrsl
      clipboard_mrsl
      pinterest_mrsl
      linkedin_mrsl
      googleplus_mrsl
      facebook_media_mrsl
      twitter_media_mrsl
      clipboard_media_mrsl
      pinterest_media_mrsl
      linkedin_media_mrsl
      googleplus_media_mrsl
    )
  end

  included do
    store_accessor :mrsl, Mrslable.mrsl_mediums
  end
end
