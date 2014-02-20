class CreateLike < ActiveInteraction::Base
  model   :morsel, :user

  validates :morsel, presence: true
  validates :user, presence: true
  validate :user_has_not_liked_morsel_already

  def execute
    morsel.likers << user
  end

  private

  def user_has_not_liked_morsel_already
    errors.add(:morsel, 'already liked') if morsel.likers.include? user
  end
end
