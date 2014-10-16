class DevicesController < ApiController
  def create
    service = RegisterDevice.call(DeviceParams.build(params).merge(user: current_user))
    custom_respond_with_service service
  end

  class DeviceParams
    def self.build(params, _scope = nil)
      params.require(:device).permit(:name, :token, :user_id, :model)
    end
  end

  private
end
