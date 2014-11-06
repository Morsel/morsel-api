class ChangeMorselCreator
  include Service

  attribute :morsel, Morsel
  attribute :new_creator, User

  validates :morsel, presence: true
  validates :new_creator, presence: true
  validate :morsel_has_creator?

  def call
    errors.add(:morsel, 'unable to update morsel') unless update_morsel
    errors.add(:items, 'unable to update items') unless update_items

    morsel
  end

  private

  def morsel_has_creator?
    errors.add(:morsel, 'has no existing creator') unless old_creator
  end

  def old_creator
    morsel.creator if morsel
  end

  def update_morsel
    old_creator.remove_role :creator, morsel
    new_creator.add_role :creator, morsel
    new_url = "#{Settings.morsel.web_url}/#{new_creator.username}/#{morsel.id}-#{morsel.cached_slug}"
    morsel.update creator_id: new_creator.id, cached_url: new_url
  end

  def update_items
    morsel.items.each do |item|
      old_creator.remove_role :creator, item
      new_creator.add_role :creator, item
    end
    morsel.items.update_all creator_id: new_creator.id
  end
end
