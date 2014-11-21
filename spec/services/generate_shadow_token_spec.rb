require 'spec_helper'

describe GenerateShadowToken do
  let(:user) { FactoryGirl.create(:user) }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      user: user
    }}
  end

  it 'should create a ticket' do
    call_service user: user

    expect_service_success
    expect(service_response).to_not eq(nil)
  end
end
