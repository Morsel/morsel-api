class PublishMorsel
  include Service

  attribute :morsel, Morsel
  attribute :morsel_params, Hash
  attribute :social_params, Hash
  attribute :should_republish, Boolean, default: false

  validates :morsel, presence: true
  validate :title_exists?
  validate :primary_item_exists?

  def call
    if should_republish ? PublishMorselDecorator.new(morsel).republish : PublishMorselDecorator.new(morsel).publish(safe_social_params)
      morsel.reload
    else
      errors.add(:morsel, 'unable to publish')
    end
  end

  private

  def set_primary_item_id_if_specified
    morsel.primary_item_id = primary_item_id if primary_item_id
  end

  def primary_item_id
    @primary_item_id ||= safe_morsel_params[:primary_item_id]
  end

  # morsel_params doesn't correctly default to empty Hash (even when passing default: {}), so use this safe method instead and also symbolize the keys
  def safe_morsel_params
    @safe_morsel_params ||= morsel_params ? morsel_params.symbolize_keys : {}
  end

  def safe_social_params
    @safe_social_params ||= social_params ? social_params.symbolize_keys : {}
  end

  def primary_item_exists?
    set_primary_item_id_if_specified
    errors.add(:cover_photo, 'is required') if morsel.primary_item.nil?
  end

  def title_exists?
    errors.add(:title, 'is required') if morsel.title.blank?
  end
end
