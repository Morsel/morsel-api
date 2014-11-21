require 'spec_helper'

describe SendPushNotification do
  let(:notification) { FactoryGirl.create(:item_comment_activity_notification) }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      notification: notification
    }}
  end

  context 'receiver has devices' do
    let(:device) { FactoryGirl.create(:device, user: notification.user) }

    Device.notification_setting_keys.each do |notification_setting_key|
      describe notification_setting_key do
        let(:notification) { FactoryGirl.create("#{notification_setting_key.to_s.sub('notify_', '')}_activity_notification") }

        context 'is enabled' do
          before { device.update "#{notification_setting_key}" => true }

          it 'should send the notification' do
            stub_apns_client

            call_service notification: notification

            expect_service_success
            expect(service_response.first).to_not be_nil
            expect(service_response.first.custom).to eq(ApnsNotificationDecorator.new(notification).custom_payload)
          end
        end

        context 'is disabled' do
          before { device.update "#{notification_setting_key}" => false }

          it 'should NOT send the notification' do
            stub_apns_client

            call_service notification: notification

            expect_service_success
            expect(service_response).to be_empty
          end
        end
      end
    end
  end

  context 'receiver has no devices' do
    before do
      notification.marked_read_at = DateTime.now
      notification.sent_at = DateTime.now
    end

    it 'returns false' do
      call_service notification: notification

      expect_service_success
      expect(service_response).to be_false
    end
  end

  context 'notification already read' do
    before { notification.marked_read_at = DateTime.now }

    it 'returns false' do
      call_service notification: notification

      expect_service_success
      expect(service_response).to be_false
    end
  end

  context 'notification already sent' do
    before { notification.sent_at = DateTime.now }

    it 'returns false' do
      call_service notification: notification

      expect_service_success
      expect(service_response).to be_false
    end
  end

  context 'notification payload is missing' do
    before { notification.payload = nil }
    it 'throws an error' do
      call_service notification: notification

      expect_service_failure
    end
  end

  context 'notification user is missing' do
    before { notification.user = nil }
    it 'throws an error' do
      call_service notification: notification

      expect_service_failure
    end
  end
end
