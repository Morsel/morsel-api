class PublishedMorselHipChatNotificationWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])

    SendHipChatNotification.call(message: "\"#{morsel.title}\" was published! #{morsel.url} #{morsel.photo_url}")
  end
end
