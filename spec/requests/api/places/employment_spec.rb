require_relative '_spec_helper'

describe 'POST /places/join employments#create' do
  let(:endpoint) { '/places/join' }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:title) { Faker::Name.title }

  before { stub_foursquare_venue }

  context 'Place already exists in API' do
    let(:place) { FactoryGirl.create(:place) }

    it 'employs `current_user` at the Place with the specified `foursquare_venue_id`' do
      post_endpoint place: {
                      foursquare_venue_id: place.foursquare_venue_id,
                      name: place.name,
                      address: place.address,
                      city: place.city,
                      state: place.state
                    }, title: title

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
    let(:place) { FactoryGirl.build(:place) }

    it 'creates a Place and employs `current_user` there' do
      post_endpoint place: {
                      foursquare_venue_id: place.foursquare_venue_id,
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
        post_endpoint place: {
                        foursquare_venue_id: place.foursquare_venue_id
                      }, title: title
      }.to change(FoursquareImportWorker.jobs, :size).by(1)
    end
  end
end

describe 'POST /places/:id|:foursquare_venue_id/employment employments#create' do
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:title) { Faker::Name.title }

  before { stub_foursquare_venue }

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

describe 'DELETE /places/:id/employment employments#destroy' do
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
