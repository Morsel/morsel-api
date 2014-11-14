class NotifyTaggedMorselUsersWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.includes(:morsel_user_tags).find(options['morsel_id'])

    Activity.where(action_id: morsel.morsel_user_tag_ids, action_type: MorselUserTag, subject: morsel).find_each do |activity|
      CreateNotification.call(
        payload: activity,
        user_id: activity.action.user_id
      )
    end
  end
end
