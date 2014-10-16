class RegisterDevice
  include Service

  attribute :user, User
  attribute :name, String
  attribute :token, String
  attribute :model, String

  validates :user, presence: true
  validates :name, presence: true
  validates :token, presence: true
  validates :model, presence: true

  def call
    return existing_device if device_already_exists_for_user?

    if new_device.save
      destroy_existing_device
    else
      errors.add :device, new_device.errors
    end

    new_device
  end

  private

  def device_attributes
    attributes.except :user
  end

  def device_already_exists_for_user?
    existing_device && existing_device.user == user
  end

  def destroy_existing_device
    existing_device.destroy if existing_device
  end

  def existing_device
    @existing_device ||= Device.includes(:user).find_by model: model, token: token
  end

  def new_device
    @new_device ||= user.devices.new(device_attributes)
  end
end
