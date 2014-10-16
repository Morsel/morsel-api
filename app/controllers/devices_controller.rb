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

  class DeviceParams
    def self.build(params, _scope = nil)
      params.require(:device).permit(:name, :token, :user_id, :model)
    end
  end

  private
end
