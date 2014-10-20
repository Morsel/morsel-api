module UserCreatable
  extend ActiveSupport::Concern

  included do
    before_save :ensure_creator_role
    resourcify
  end

  private

  def ensure_creator_role
    if defined?(creator) && creator
      creator.add_role(:creator, self)
    elsif defined?(user) && user
      user.add_role(:creator, self)
    end
  end
end
