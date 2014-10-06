class NotifyTaggedMorselUsersWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])

    Activity.where(action_id: morsel.morsel_user_tag_ids, action_type: MorselUserTag).find_each do |activity|
      CreateNotification.call(
        payload: activity,
        user_id: activity.recipient_id
      )
    end
  end
end
