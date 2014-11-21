class SubscribeUserToMorselItemsWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    user = User.find(options['user_id'])

    Item.where(morsel_id:options['morsel_id']).find_each do |item|
      item.add_subscriber(user, options['actions'], options['reason'], options['active'])
    end
  end
end
