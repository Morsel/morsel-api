module UserEventCreator
  extend ActiveSupport::Concern

  def queue_user_event(name, user_id = nil, properties = nil)
    CreateUserEventWorker.perform_async(
      name: name,
      user_id: user_id || current_user.id,
      __utmz: params[:__utmz].presence,
      client: params[:client],
      properties: properties
    )
  end
end
