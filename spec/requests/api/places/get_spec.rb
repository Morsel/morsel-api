require_relative '_spec_helper'

describe 'GET /places/:id places#show' do
  let(:endpoint) { "/places/#{place.id}" }
  let(:place) { FactoryGirl.create(:place) }

  it 'returns a Place for the specified `id`' do
    get_endpoint
    expect_success

    expect_json_data_eq({
      'id' => place.id,
      'name' => place.name,
      'slug' => place.slug,
      'address' => place.address,
      'city' => place.city,
      'state' => place.state,
      'postal_code' => place.postal_code,
      'country' => place.country,
      'facebook_page_id' => place.facebook_page_id,
      'twitter_username' => place.twitter_username,
      'foursquare_venue_id' => place.foursquare_venue_id,
      'following' => false,
      'information' => {
        'website_url' => place.information['website_url'],
        'formatted_phone' => place.information['formatted_phone'],
        'price_tier' => place.information['price_tier'],
        'reservations_url' => place.information['reservations_url'],
        'menu_url' => place.information['menu_url'],
        'menu_mobile_url' => place.information['menu_mobile_url'],
        'reservations' => place.information['reservations'],
        'credit_cards' => place.information['credit_cards'],
        'outdoor_seating' => place.information['outdoor_seating'],
        'dining_options' => place.information['dining_options'],
        'dress_code' => place.information['dress_code'],
        'dining_style' => place.information['dining_style'],
        'public_transit' => place.information['public_transit'],
        'parking' => place.information['parking'],
        'parking_details' => place.information['parking_details']
      }
    })
  end

  context '`current_user` is following Place' do
    let(:current_user) { FactoryGirl.create(:chef) }
    before { current_user.followed_places << place }

    it 'returns `following` true' do
      get_endpoint
      expect_success

      expect_json_data_eq({
        'id' => place.id,
        'following' => true
      })
    end
  end
end
