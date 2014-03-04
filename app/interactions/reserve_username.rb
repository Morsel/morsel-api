class ReserveUsername < ActiveInteraction::Base
  string  :email, :username

  validates :email,
            format: { with: /\A[^@]+@[^@]+\z/ },
            presence: true
  validates :username,
            format: { with: /\A[a-zA-Z][A-Za-z0-9_]+$\z/ },
            length: { maximum: 15 },
            presence: true

  def execute
    User.create(
      email: email,
      username: username,
      password: Devise.friendly_token,
      active: false
    )
  end
end
