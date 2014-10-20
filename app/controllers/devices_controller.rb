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

    notification_settings_params = DeviceParams.build(params)[:notification_settings]
    Device.notification_setting_keys.each do |notification_setting_key|
      device.send("#{notification_setting_key}=", notification_settings_params[notification_setting_key]) unless notification_settings_params[notification_setting_key].nil?
    end

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
      params.require(:device).permit(:name, :token, :user_id, :model, notification_settings: Device.notification_setting_keys)
    end
  end

  private

  authorize_actions_for Device
end
