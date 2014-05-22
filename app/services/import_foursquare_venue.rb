class ImportFoursquareVenue
  include Service

  attribute :place, Place
  validates :place, presence: true

  VALID_TYPES = %w(
    diningOptions
    outdoorSeating
    payments
    reservations
  )

  def call
    if foursquare_venue
      return if place.recently_imported?

      place.name = foursquare_venue['name']
      place.information['website_url'] = foursquare_venue['url']

      import_attributes if foursquare_venue['attributes'].present?
      import_contact if foursquare_venue['contact'].present?
      import_hours if foursquare_venue['hours'].present?
      import_location if foursquare_venue['location'].present?
      import_menu if foursquare_venue['menu'].present?
      import_price if foursquare_venue['price'].present?
      import_reservations if foursquare_venue['reservations'].present?

      place.last_imported_at = DateTime.now
      place.save
    else
      delete_place
    end
  end

  private

  def foursquare_venue
    @foursquare_venue ||= Foursquare2::Client.new(Settings.foursquare).venue(place.foursquare_venue_id)
  rescue Foursquare2::APIError
    nil
  end

  def delete_place
    if place.last_imported_at.nil?
      # Delete the Place if it's never been imported before. This means someone provided an invalid `foursquare_venue_id`
      place.destroy if place.persisted?
      nil
    else
      # Update last_imported_at to make this place not get imported again right away
      place.update(last_imported_at: DateTime.now)
    end
  end

  def extract_foursquare_attributes(foursquare_attributes)
    results = {}
    foursquare_attributes['groups'].each do |group|
      if VALID_TYPES.include? group['type']
        results[group['type'].underscore] = group['items'].map { |a| a['displayValue'] }.join('; ')
      end
    end

    results
  end

  def import_attributes
    place.information.merge(extract_foursquare_attributes(foursquare_venue['attributes']))
  end

  def import_contact
    place.twitter_username =              foursquare_venue['contact']['twitter']
    place.information['formatted_phone'] = foursquare_venue['contact']['formattedPhone']
  end

  def import_hours
    place.foursquare_timeframes = foursquare_venue['hours']['timeframes']
  end

  def import_location
    place.address =     foursquare_venue['location']['address']
    place.city =        foursquare_venue['location']['city']
    place.state =       foursquare_venue['location']['state']
    place.postal_code = foursquare_venue['location']['postalCode']
    place.country =     foursquare_venue['location']['country']
  end

  def import_menu
    place.information['menu_url'] =        foursquare_venue['menu']['url']
    place.information['menu_mobile_url'] = foursquare_venue['menu']['mobileUrl']
  end

  def import_price
    place.information['price_tier'] = foursquare_venue['price']['tier']
  end

  def import_reservations
    place.information['reservations_url'] = foursquare_venue['reservations']['url']
  end
end
