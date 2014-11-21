require 'spec_helper'

describe ImportFoursquareVenue do
  let(:place) { FactoryGirl.build(:place) }
  let(:title) { Faker::Name.title }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      place: place
    }}
  end

  context 'Place exists on Foursquare' do
    let(:foursquare_name) { Faker::Company.name }
    let(:foursquare_stub_options) {{ foursquare_venue_id: place.foursquare_venue_id, name: foursquare_name }}

    before { stub_foursquare_venue foursquare_stub_options }

    context 'last imported over 30 days ago' do
      before { place.last_imported_at = 31.days.ago }
      it 'overwrites existing API data' do
        call_service place: place

        expect_service_success

        expect(place.name).to eq(foursquare_name)
        expect(place.persisted?).to be_true
      end
    end

    context 'recently imported from Foursquare' do
      before { place.last_imported_at = 20.days.ago }
      it 'does NOT import the data' do
        call_service place: place

        expect_service_success

        expect(place.name).to_not eq(foursquare_name)
        expect(place.persisted?).to be_false
      end
    end
  end

  context 'Place does NOT exist on Foursquare' do
    before { stub_foursquare_venue_not_found }

    context 'Place has been imported before' do
      before { place.last_imported_at = 5.days.ago }

      it 'does NOT delete the Place and Employments but does update `last_imported_at`' do
        expect {
          call_service place: place
        }.to change(place, :last_imported_at)

        expect_service_success
      end

      # it 'should send a notification to let us know' # TODO: Abstract some type of notifier around Rollbar and utilize that
    end

    context 'Place has NOT been imported before' do
      it 'soft deletes the Place and all Employments' do

        call_service place: place

        expect_service_success
      end
    end
  end
end
