class UnsubscribeFromSubjectActivityWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    subject = options['subject_type'].constantize.find options['subject_id']
    subscriber = User.find options['subscriber_id']

    UnsubscribeFromSubjectActivity.call(
      subject: subject,
      subscriber: subscriber,
      actions: options['actions'],
      reason: options['reason']
    )
  end
end
