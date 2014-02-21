class CheckUsernameExists < ActiveInteraction::Base
  string  :username

  validates :username,
            format: { with: /\A[a-zA-Z][A-Za-z0-9_]+$\z/ },
            length: { maximum: 15 },
            presence: true

  def execute
    # Say non username paths are existing usernames for simplicity
    non_username_path? || User.where(username: username).count > 0
  end

  private

  def non_username_path?
    ReservedPaths.non_username_paths.include? username
  end
end
