require 'spec_helper'

describe 'Misc. API Methods' do
  describe 'GET /status status#show' do
    let(:endpoint) { '/status' }
    it 'pings the API' do
      get_endpoint

      expect_success
    end
  end

  describe 'GET /configuration configuration#show' do
    let(:endpoint) { '/configuration' }

    it 'returns an array of non username paths' do
      get_endpoint

      expect_success
      expect_json_data_eq('non_username_paths' => ReservedPaths.non_username_paths)
    end
  end
end
