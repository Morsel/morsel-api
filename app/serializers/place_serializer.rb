class PlaceSerializer < SlimPlaceSerializer
  attributes  :lat,
              :lon,
              :facebook_page_id,
              :twitter_username,
              :foursquare_venue_id,
              :foursquare_timeframes,
              :information
end
