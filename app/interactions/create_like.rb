class CreateLike < ActiveInteraction::Base
  model   :morsel, :user

  validates :morsel, presence: true
  validates :user, presence: true
  validate { errors.add(:user, 'not authorized to create Like') unless user.can_create?(Like) }
  validate :user_has_not_liked_morsel_already

  def execute
    morsel.likers << user
  end

  private

  def user_has_not_liked_morsel_already
    errors.add(:morsel, 'already liked') if morsel.likers.include? user
  end
end