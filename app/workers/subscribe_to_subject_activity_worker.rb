class SubscribeToSubjectActivityWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    subject = options['subject_type'].constantize.find options['subject_id']
    subscriber = User.find options['subscriber_id']

    SubscribeToSubjectActivity.call(
      subject: subject,
      subscriber: subscriber,
      actions: options['actions'],
      reason: options['reason'],
      active: options['active']
    )
  end
end
