module Mrslable
  extend ActiveSupport::Concern

  def self.mrsl_mediums
    [
      :facebook_mrsl,
      :twitter_mrsl,
      :clipboard_mrsl,
      :facebook_media_mrsl,
      :twitter_media_mrsl,
      :clipboard_media_mrsl,
      :pinterest_media_mrsl,
      :linkedin_media_mrsl,
      :googleplus_media_mrsl
    ]
  end

  included do
    store_accessor :mrsl, Mrslable.mrsl_mediums
  end
end
