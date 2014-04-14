module Feedable
  extend ActiveSupport::Concern

  included do
    has_one :feed_item, as: :subject, dependent: :destroy

    after_save :update_visibility
  end

  private

  def update_visibility
    if self.feed_item
      if self.published_at_changed? || self.draft_changed?
        self.feed_item.update(visible: !self.draft)
      elsif self.changed?
        self.feed_item.touch
      end
    end
  end
end
