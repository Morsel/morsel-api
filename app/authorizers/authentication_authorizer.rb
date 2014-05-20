class AuthenticationAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    # Any User can CREATE an Authentication
    user.present?
  end
end
