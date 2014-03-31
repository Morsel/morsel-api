class FeedWorker
  include Sidekiq::Worker

  def perform(subject_id, subject_type)
    FeedItem.create!(
      subject_id: subject_id,
      subject_type: subject_type
    )
  end
end
