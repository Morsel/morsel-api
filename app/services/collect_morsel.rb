class CollectMorsel
  include Service

  attribute :morsel, Morsel
  attribute :collection # Since virtus has its own Collecton, don't specify the class
  attribute :user, User
  attribute :validated, Boolean # Hack since .valid? calls morsel_already_in_collection? after it's been run

  validates :morsel, presence: true
  validates :collection, presence: true
  validates :user, presence: true

  validate :user_is_collection_user?
  validate :morsel_already_in_collection?

  def call
    self.validated = true
    collection.morsels << morsel
  end

  private

  def user_is_collection_user?
    errors.add(:user, 'not authorized to add to this collection') unless user && user.id == collection.user_id
  end

  def morsel_already_in_collection?
    errors.add(:morsel, 'already in this collection') if !validated && collection.morsels.include?(morsel)
  end
end
