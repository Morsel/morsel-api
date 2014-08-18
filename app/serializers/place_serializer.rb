class PlaceSerializer < SlimPlaceSerializer
  attributes  :facebook_page_id,
              :twitter_username,
              :foursquare_venue_id,
              :foursquare_timeframes,
              :information,
              :following

  def following
    scope.present? && scope.following_place?(object)
  end
end
