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
    User.find(user_id).update(type: role.capitalize)
  end
end
