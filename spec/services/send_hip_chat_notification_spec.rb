require 'spec_helper'

describe SendHipChatNotification do
  let(:service_class) { described_class }
  let(:message) { 'Test HipChat Notification' }
  let(:expected_response) { true }
  let(:test_room) { 'test_room' }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      message: message
    }}
  end

  it 'should send a notification' do
    stub_settings(:hipchat, {
      auth_token: 't0k3n',
      default_room: test_room
    })

    stub_hipchat_client room: test_room

    call_service message: message

    expect_service_success
    expect(service_response).to eq(expected_response)
  end
end
