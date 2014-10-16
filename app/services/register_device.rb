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
    existing_device = Device.includes(:user).find_by model: model, token: token
    return existing_device if existing_device && existing_device.user == user

    if new_device.save
      existing_device.destroy if existing_device
    else
      errors.add :device, new_device.errors
    end

    new_device
  end

  private

  def device_attributes
    attributes.except :user
  end

  def new_device
    @new_device ||= user.devices.new(device_attributes)
  end
end
