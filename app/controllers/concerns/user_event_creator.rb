module UserEventCreator
  extend ActiveSupport::Concern

  def queue_user_event(name, user_id = nil, properties = {})
    properties[:request_remote_ip] = request.remote_ip
    properties[:request_path] = request.path
    properties[:request_method] = request.method

    CreateUserEventWorker.perform_async(
      name: name,
      user_id: user_id || current_user_id,
      __utmz: params[:__utmz].presence,
      client: params[:client],
      properties: properties
    )
  end

  private

  def current_user_id
    current_user.id if current_user.present?
  end
end
