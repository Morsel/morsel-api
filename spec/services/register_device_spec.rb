require 'spec_helper'

describe RegisterDevice do
  let(:service_class) { described_class }

  let(:user) { FactoryGirl.create(:user) }
  let(:name) { "#{Faker::Name.name}'s Device" }
  let(:token) { Faker::Lorem.characters(32) }
  let(:model) { "iphone" }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      user: user,
      name: name,
      token: token,
      model: model
    }}
  end

  it 'should create a device' do
    call_service ({
      user: user,
      name: name,
      token: token,
      model: model
    })

    expect_service_success
    expect(service_response).to eq(Device.last)
  end

  context 'device already exists' do
    before { existing_device }

    context 'for the same User' do
      let(:existing_device) { FactoryGirl.create(:device, token: token, model: model, user: user) }

      it 'should return that device' do
        call_service ({
          user: user,
          name: name,
          token: token,
          model: model
        })

        expect_service_success
        expect(service_response).to eq(existing_device)
      end
    end

    context 'for another User' do
      let(:existing_device) { FactoryGirl.create(:device, token: token, model: model) }

      it 'should create a new device and destroy the other User\'s device' do
        call_service ({
          user: user,
          name: name,
          token: token,
          model: model
        })

        expect_service_success
        expect(service_response).to be_a(Device)
        expect(service_response).to_not eq(existing_device)
        expect(existing_device.reload.deleted_at).to_not be_nil
      end
    end
  end
end
