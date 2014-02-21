require 'spec_helper'

describe 'Misc. API Methods' do
  describe 'GET /status status#show' do
    it 'pings the API' do
      get '/status',  format: :json

      expect(response).to be_success
    end
  end

  describe 'GET /configuration configuration#show' do
    let(:user) { FactoryGirl.create(:user) }

    it 'returns an array of non username paths' do
      get '/configuration', api_key: api_key_for_user(user), format: :json

      expect(response).to be_success

      expect(json_data['non_username_paths']).to eq(ReservedPaths.non_username_paths)
    end
  end
end
