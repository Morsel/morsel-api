class PublishMorselDecorator < SimpleDelegator
  def publish(options = {})
    self.publishing = true
    if save
      PublishMorselWorker.perform_async(
        morsel_id: id,
        place_id: place_id,
        user_id: user_id,
        post_to_facebook: options[:post_to_facebook],
        post_to_twitter: options[:post_to_twitter]
      )
      true
    else
      false
    end
  end

  def unpublish
    feed_item.destroy && update(draft: true, published_at: nil)
  end

  def republish
    unpublish && publish
  end
end
