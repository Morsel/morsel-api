class UncollectMorsel
  include Service

  attribute :morsel, Morsel
  attribute :collection # Since virtus has its own Collecton, don't specify the class
  attribute :user, User
  attribute :validated, Boolean # Hack since .valid? calls morsel_in_collection? after it's been run

  validates :morsel, presence: true
  validates :collection, presence: true
  validates :user, presence: true

  validate :user_is_collection_user?
  validate :morsel_in_collection?

  def call
    self.validated = true
    collection.morsels.delete morsel
    collection.morsels
  end

  private

  def user_is_collection_user?
    errors.add(:user, 'not authorized to remove from this collection') unless user && user.id == collection.user_id
  end

  def morsel_in_collection?
    errors.add(:morsel, 'not in this collection') if !validated && collection.morsels.exclude?(morsel)
  end
end
