class CheckUsernameExists < ActiveInteraction::Base
  string  :username

  validates :username,
            format: { with: /\A[a-zA-Z][A-Za-z0-9_]+$\z/ },
            length: { maximum: 15 },
            presence: true

  def execute
    User.where(username: username).count > 0
  end
end
