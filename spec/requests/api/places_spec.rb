require 'spec_helper'

describe 'Places API' do
  it_behaves_like 'FollowableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:followable_route) { '/places' }
    let(:followable) { FactoryGirl.create(:existing_place) }
  end

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
  end

  describe 'POST /places/:id|:foursquare_venue_id/employment places#employment' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:title) { Faker::Name.title }
    let(:foursquare_stub_options) { {} }

    before { stub_foursquare_venue(foursquare_stub_options) }

    context 'no `title` passed' do
      let(:endpoint) { '/places/0/employment' }
      it 'should return an error' do
        post_endpoint

        expect_failure
        expect_missing_param_error_for_param('title')
      end
    end

    context '`id`' do
      context 'Place already exists in API' do
        let(:endpoint) { "/places/#{place.id}/employment" }
        let(:place) { FactoryGirl.create(:place) }

        it 'employs `current_user` at the Place with the specified `id`' do
          post_endpoint title: title

          expect_success

          expect_json_data_eq({
            'id' => place.id,
            'name' => place.name,
            'slug' => place.slug,
            'address' => place.address,
            'city' => place.city,
            'state' => place.state,
            'country' => place.country
          })

          place.reload
          expect(place.users.include?(current_user)).to be_true
        end

        it 'returns the User\'s `title` in the response' do
          post_endpoint title: title

          expect_success
          expect_json_data_eq('title' => title)
        end
       end

      context 'Place does not exist in API' do
        let(:endpoint) { "/places/0/employment" }
        it 'returns an error' do
          post_endpoint title: title

          expect_failure
          expect_record_not_found_error
        end
      end
    end

    context '`foursquare_venue_id`' do
      context 'Place already exists in API' do
        let(:endpoint) { "/places/#{place.foursquare_venue_id}/employment" }
        let(:place) { FactoryGirl.create(:place) }

        it 'employs `current_user` at the Place with the specified `foursquare_venue_id`' do
          post_endpoint title: title

          expect_success

          expect_json_data_eq({
            'id' => place.id,
            'name' => place.name,
            'slug' => place.slug,
            'address' => place.address,
            'city' => place.city,
            'state' => place.state,
            'country' => place.country
          })

          place.reload
          expect(place.users.include?(current_user)).to be_true
        end
      end

      context 'Place does not exist in API' do
        let(:endpoint) { "/places/#{place.foursquare_venue_id}/employment" }
        let(:place) { FactoryGirl.build(:place) }

        it 'creates a Place and employs `current_user` there' do
          post_endpoint place: {
                          name: place.name,
                          address: place.address,
                          city: place.city,
                          state: place.state
                        }, title: title
          expect_success
          expect_json_data_eq({
            'id' => Place.last.id,
            'name' => place.name,
            'address' => place.address,
            'city' => place.city,
            'state' => place.state
          })
          expect(Place.last.users.include?(current_user)).to be_true
        end

        it 'queues the FoursquareImportWorker' do
          expect {
            post_endpoint title: title
          }.to change(FoursquareImportWorker.jobs, :size).by(1)
        end
      end
    end
  end

  describe 'DELETE /places/:id/employment places#employment' do
    let(:endpoint) { "/places/#{place.id}/employment" }
    let(:place) { FactoryGirl.create(:place) }
    let(:current_user) { FactoryGirl.create(:chef) }

    context '`current_user` belongs to Place' do
      before { Employment.create(place: place, user: current_user) }

      it 'unemploys `current_user` at the Place with the specified `id`' do
        delete_endpoint

        expect_success

        place.reload
        expect(place.users.include?(current_user)).to_not be_true
      end
    end

    context '`current_user` does NOT belong to Place' do
      before { place }
      it 'does NOT soft delete the Employment' do
        delete_endpoint

        expect_failure
        expect(response.status).to eq(422)
        expect(json_errors['place'].first).to eq('not joined')
      end
    end

    context 'Place does not exist in API' do
      let(:endpoint) { '/places/0/employment' }
      it 'returns an error' do
        delete_endpoint

        expect_failure
        expect(json_errors['place'].first).to eq('not joined')
      end
    end
  end

  describe 'GET /places/suggest places#suggest' do
    let(:endpoint) { '/places/suggest' }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:expected_count) { 3 }

    before { stub_foursquare_suggest(count: expected_count) }

    it 'suggests Foursquare Venues' do
      get_endpoint lat_lon: '1,2', query: 'some query'
      expect_success
      expect_json_data_count expected_count
    end

    it 'renders the Foursquare response' do
      get_endpoint lat_lon: '1,2', query: 'some query'
      expect_success
      expect(json_data.first['location']).to_not be_nil
    end

    describe 'query' do
      it 'is required' do
        get_endpoint lat_lon: '1,2'
        expect_missing_param_error_for_param 'query'
      end

      it 'requires at least 3 characters' do
        get_endpoint lat_lon: '1,2', query: 'ab'
        expect_failure
        expect_first_error('query', 'is too short (minimum is 3 characters)')
      end
    end

    describe 'lat_lon' do
      it 'is required' do
        get_endpoint query: 'asdf'
        expect_missing_param_error_for_param 'lat_lon'
      end
    end
  end

  describe 'GET /places/:id/morsels' do
    let(:endpoint) { "/places/#{place.id}/morsels" }
    let(:place) { FactoryGirl.create(:place) }
    let(:place_morsels_count) { rand(2..6) }

    before do
      place_morsels_count.times { FactoryGirl.create(:morsel_with_creator, place: place) }
    end

    it 'returns Morsels associated with the Place' do
      get_endpoint

      expect_success
      expect_json_data_count place_morsels_count
    end
  end

  describe 'GET /places/:id/users' do
    let(:endpoint) { "/places/#{place.id}/users" }
    let(:place) { FactoryGirl.create(:place) }
    let(:place_users_count) { rand(2..6) }

    before do
      place_users_count.times { FactoryGirl.create(:employment, place: place) }
    end

    it 'returns Users associated with the Place' do
      get_endpoint

      expect_success

      expect_json_data_count place_users_count

      expect_first_json_data_eq title: Employment.last.title
    end
  end
end
