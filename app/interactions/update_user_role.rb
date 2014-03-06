class UpdateUserRole < ActiveInteraction::Base
  string  :user_id, :role

  validates :user_id,
            numericality: { only_integer: true },
            presence: true
  validates :role,
            inclusion: {
              in: %w(chef diner writer),
              message: "%{value} is not a valid role"
            },
            presence: true

  def execute
    user = User.find(user_id)
    user.update(industry: role)
    errors.merge!(user.errors)
  end
end
