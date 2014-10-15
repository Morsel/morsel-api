require_relative '_spec_helper'

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

  describe 'lat_lon or near' do
    it 'is required' do
      get_endpoint query: 'asdf'
      expect_first_error 'lat_lon_or_near', 'is required'
    end
  end
end
