class DeviceAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    user == resource.user
  end

  def deletable_by?(user)
    user == resource.user
  end
end
