class CollectMorsel
  include Service

  attribute :morsel, Morsel
  attribute :collection # Since virtus has its own Collecton, don't specify the class
  attribute :note, String
  attribute :user, User
  attribute :validated, Boolean # Hack since .valid? calls morsel_already_in_collection? after it's been run

  validates :morsel, presence: true
  validates :collection, presence: true
  validates :user, presence: true

  validate :user_is_collection_user?
  validate :morsel_already_in_collection?
  validate :morsel_is_published?

  def call
    self.validated = true
    collection_morsel = CollectionMorsel.new(morsel: morsel, collection: collection, note: note)

    if collection_morsel.save
      decorated_collected_morsel
    else
      errors.add(:collection_morsel, collection_morsel.errors)
    end
  end

  private

  def decorated_collected_morsel
    collected_morsel = CollectedMorselDecorator.new(morsel)
    collected_morsel.note = note
    collected_morsel
  end

  def user_is_collection_user?
    errors.add(:user, 'not authorized to add to this collection') unless user && user.id == collection.user_id
  end

  def morsel_already_in_collection?
    errors.add(:morsel, 'already in this collection') if !validated && collection.morsels.include?(morsel)
  end

  def morsel_is_published?
    errors.add(:morsel, 'not published') if !validated && morsel.draft?
  end
end
