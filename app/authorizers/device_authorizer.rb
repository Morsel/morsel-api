class DeviceAuthorizer < ApplicationAuthorizer
  def deletable_by?(user)
    user == resource.user
  end
end
