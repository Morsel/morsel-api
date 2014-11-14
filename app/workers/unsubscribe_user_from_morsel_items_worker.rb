class UnsubscribeUserFromMorselItemsWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user_id'])

    Item.where(morsel_id:options['morsel_id']).find_each do |item|
      item.remove_subscriber(user, options['actions'], options['reason'])
    end
  end
end
