class DevicesController < ApiController
  def index
    custom_respond_with Device.paginate(pagination_params)
                              .where(user_id: current_user.id)
                              .order(Device.arel_table[:id].desc)
  end

  def create
    service = RegisterDevice.call(DeviceParams.build(params).merge(user: current_user))
    custom_respond_with_service service
  end

  def update
    device = Device.find(params[:id])
    authorize_action_for device

    notification_settings = DeviceParams.build(params)[:notification_settings]
    device.notify_comments_on_my_morsel= notification_settings[:notify_comments_on_my_morsel] unless notification_settings[:notify_comments_on_my_morsel].nil?
    device.notify_likes_my_morsel= notification_settings[:notify_likes_my_morsel] unless notification_settings[:notify_likes_my_morsel].nil?
    device.notify_new_followers= notification_settings[:notify_new_followers] unless notification_settings[:notify_new_followers].nil?

    if device.save
      custom_respond_with device
    else
      render_json_errors device.errors
    end
  end

  def destroy
    device = Device.find(params[:id])
    authorize_action_for device

    if device.destroy
      render_json_ok
    else
      render_json_errors(device.errors)
    end
  end

  class DeviceParams
    def self.build(params, _scope = nil)
      params.require(:device).permit(:name, :token, :user_id, :model, notification_settings: [:notify_comments_on_my_morsel, :notify_likes_my_morsel, :notify_new_followers])
    end
  end

  private

  authorize_actions_for Device
end
