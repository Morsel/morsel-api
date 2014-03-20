module UserEventCreator
  extend ActiveSupport::Concern

  def create_user_event(name, user_id = nil)
    user_event = UserEvent.new

    user_event.name = name
    user_event.user_id = user_id ? user_id : current_user.id

    user_event._ga = params[:_ga].presence
    if params[:client].present?
      user_event.client_device = params[:client][:device]
      user_event.client_version = params[:client][:version]
    end

    user_event.save
  end
end
