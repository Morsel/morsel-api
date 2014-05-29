class PlaceSerializer < SlimPlaceSerializer
  attributes  :facebook_page_id,
              :twitter_username,
              :foursquare_venue_id,
              :foursquare_timeframes,
              :information
end
