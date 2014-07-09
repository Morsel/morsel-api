class PlaceSerializer < SlimPlaceSerializer
  attributes  :facebook_page_id,
              :twitter_username,
              :foursquare_venue_id,
              :foursquare_timeframes,
              :information,
              :following

  def following
    current_user.present? && current_user.following_place?(object)
  end
end
