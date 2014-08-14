class PublishMorselDecorator < SimpleDelegator
  def publish!(options = {})
    # TODO: Crap out if already published
    self.draft = false
    if self.save
      PublishMorselWorker.perform_async(
        morsel_id: self.id,
        place_id: self.place_id,
        user_id: self.user_id,
        post_to_facebook: options[:post_to_facebook],
        post_to_twitter: options[:post_to_twitter]
      )
      true
    else
      false
    end
  end

  def unpublish!
    # TODO: Crap out if not already published
    feed_item.destroy
    update draft: true, published_at: nil
  end

  def republish!
    unpublish!
    publish!
  end
end