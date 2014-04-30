class ApplicationAuthorizer < Authority::Authorizer
  def self.default(adjective, user)
    user.has_role? :admin
  end

  def self.creatable_by?(user)
    # By default, only Admin and Chef can CREATE resources
    user.has_role?(:admin) || user.has_role?(:chef)
  end

  def self.readable_by?(user)
    # By default, anyone can READ resources
    true
  end

  def self.updatable_by?(user)
    # By default, any User can UPDATE resources
    user.present?
  end

  def self.deletable_by?(user)
    # By default, any User can DELETE resources
    user.present?
  end

  def updatable_by?(user)
    # By default, only Admin and the resource's Creator can UPDATE resources
    user.has_role?(:admin) || user.has_role?(:creator, resource)
  end

  def deletable_by?(user)
    # By default, only Admin and the resource's Creator can DELETE resources
    user.has_role?(:admin) || user.has_role?(:creator, resource)
  end

  # Use in place of checking if readable && creatable ... etc.
  # https://github.com/nathanl/authority/wiki/Grouping%20Abilities%20Together
  # def manageable_by?(user)
  #   user.has_role?(:admin)
  # end
end
