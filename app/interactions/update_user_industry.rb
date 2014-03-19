class UpdateUserIndustry < ActiveInteraction::Base
  string  :user_id, :industry

  validates :user_id,
            numericality: { only_integer: true },
            presence: true
  validates :industry,
            inclusion: {
              in: %w(chef media diner),
              message: '%{value} is not a valid industry'
            },
            presence: true

  def execute
    user = User.find(user_id)
    user.update(industry: industry)
    errors.merge!(user.errors)
  end
end
