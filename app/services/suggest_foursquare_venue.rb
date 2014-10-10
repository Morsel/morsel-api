class SuggestFoursquareVenue
  include Service

  attribute :query, String
  attribute :lat_lon, String
  attribute :near, String

  validates :query, length: { minimum: 3 }

  def call
    if lat_lon
      foursquare_client.suggest_completion_venues(query: query, ll: lat_lon)
    else
      foursquare_client.suggest_completion_venues(query: query, near: near)
    end
  end

  private

  def foursquare_client
    Foursquare2::Client.new Settings.foursquare
  end
end
