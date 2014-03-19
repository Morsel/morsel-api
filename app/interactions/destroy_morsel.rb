class DestroyMorsel < ActiveInteraction::Base
  model   :morsel, :user

  validates :morsel, presence: true
  validates :user, presence: true
  validate :user_can_delete_morsel?

  def execute
    morsel.destroy
    errors.merge!(morsel.errors)
    morsel
  end

  private

  def user_can_delete_morsel?
    errors.add(:user, 'not authorized to delete morsel') unless user.can_delete? morsel
  end
end
