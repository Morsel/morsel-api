module Mrslable
  extend ActiveSupport::Concern

  included do
    store_accessor :mrsl, :facebook_mrsl, :twitter_mrsl

    after_save :create_mrsl_urls
  end

  private

  def create_mrsl_urls
    # Only create the mrsl urls if they don't exist
    if !Rails.env.test? && self.mrsl.nil?
      MrslWorker.perform_async(self.id)
    end
  end
end
