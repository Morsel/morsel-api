class ProfessionalAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    user.professional?
  end
end
