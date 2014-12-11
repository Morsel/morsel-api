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

  describe '`api_key` authentication' do
    let(:endpoint) { '/api_key_check' }
    context 'user' do
      let(:user) { FactoryGirl.create(:user) }

      it 'should return OK' do
        get_endpoint api_key: api_key_for_user(user)
        expect_success
      end
    end

    context 'non-user' do
      let(:non_user_identifier) { 'some_external_service' }
      let(:authentication_token) { Faker::Lorem.characters(10) }

      before do
        stub_settings(:authentication_tokens, {
          non_user_identifier => authentication_token
        })
      end

      it 'should return OK' do
        get_endpoint api_key: "#{non_user_identifier}:#{authentication_token}"
        expect_success
      end

      context 'invalid authentication_token passed' do
        it 'should fail' do
          get_endpoint api_key: "#{non_user_identifier}:#{authentication_token}bad"
          expect_failure
        end
      end
    end

    context 'no key' do
      it 'should fail' do
        get_endpoint
        expect_failure
      end
    end
  end
end
