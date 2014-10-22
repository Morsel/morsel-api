require 'spec_helper'

describe ValidateShadowToken do
  let(:service_class) { ValidateShadowToken }

  let(:user) { FactoryGirl.create(:user) }
  let(:shadow_token) { Faker::Lorem.characters(32) }
  let(:redis_key) { "user_shadow_token/#{user.id}" }

  context 'shadow_token exists in redis' do
    before do
      redis_set redis_key, shadow_token
    end

    it 'should return true' do
      call_service({
        shadow_token: shadow_token,
        user: user
      })

      expect_service_success
      expect(service_response).to be_true
    end

    context 'wrong shadow_token is passed' do
      it 'throws an error' do
        call_service({
          shadow_token: Faker::Lorem.characters(32),
          user: user
        })

        expect_service_failure
      end
    end
  end

  context 'key does NOT exist on redis' do
    it 'throws an error' do
      call_service({
        shadow_token: Faker::Lorem.characters(32),
        user: user
      })

      expect_service_failure
    end
  end

  context 'no shadow_token specified' do
    it 'throws an error' do
      call_service user: user

      expect_service_failure
    end
  end

  context 'no user specified' do
    it 'throws an error' do
      call_service shadow_token: shadow_token

      expect_service_failure
    end
  end
end
