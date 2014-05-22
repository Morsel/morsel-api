class SuggestFoursquareVenue
  include Service

  attribute :query, String
  attribute :lat_lon, String

  validates :query, length: { minimum: 3 }

  def call
    foursquare_client.suggest_completion_venues(query: query, ll: lat_lon)
  end

  private

  def foursquare_client
    Foursquare2::Client.new Settings.foursquare
  end
end
