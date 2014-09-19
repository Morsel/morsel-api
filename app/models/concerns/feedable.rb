module Feedable
  extend ActiveSupport::Concern

  included do
    has_one :feed_item, as: :subject, dependent: :destroy

    after_save :update_visibility
  end

  private

  def update_visibility
    return unless feed_item
    if published_at_changed? || draft_changed?
      feed_item.update(visible: !draft)
    elsif changed?
      feed_item.touch
    end
  end
end
