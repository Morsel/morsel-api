module Mrslable
  extend ActiveSupport::Concern

  included do
    store_accessor :mrsl, :facebook_mrsl, :twitter_mrsl
  end
end
