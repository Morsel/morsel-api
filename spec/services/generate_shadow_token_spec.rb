require 'spec_helper'

describe GenerateShadowToken do
  let(:service_class) { GenerateShadowToken }

  let(:user) { FactoryGirl.create(:user) }

  it 'should create a ticket' do
    call_service user: user

    expect_service_success
    expect(service_response).to_not eq(nil)
  end

  context 'no user specified' do
    it 'throws an error' do
      call_service

      expect_service_failure
    end
  end
end
