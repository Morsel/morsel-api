class FeedWorker
  include Sidekiq::Worker

  def perform(subject_id, subject_type)
    feed_item = FeedItem.create!(
      subject_id: subject_id,
      subject_type: subject_type
    )
    feed_item.update(visible: !feed_item.subject.draft)
  end
end
