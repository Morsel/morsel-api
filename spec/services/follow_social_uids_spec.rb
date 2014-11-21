require 'spec_helper'

describe FollowSocialUids do
  context "provider is 'facebook'" do
    let(:authentication) { FactoryGirl.create(:facebook_authentication) }
    let(:number_of_connected_uids) { rand(2..6) }
    let(:number_of_not_connected_uids) { rand(2..6) }
    let(:stubbed_uids) do
      _stubbed_uids = []
      number_of_connected_uids.times { _stubbed_uids << FactoryGirl.create(:facebook_authentication).uid }
      number_of_not_connected_uids.times { _stubbed_uids << "fbuid_#{Faker::Number.number(10)}" }
      _stubbed_uids
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should follow Users matching the UIDs for user' do
      call_service({
        authentication: authentication,
        uids: stubbed_uids
      })

      expect_service_success
      expect(service_response.count).to eq(number_of_connected_uids)
      expect(authentication.user.reload.followed_user_count).to eq(number_of_connected_uids)
    end

    it 'should NOT queue any push notifications' do
      Sidekiq::Testing.inline! do
        expect {
          call_service({
            authentication: authentication,
            uids: stubbed_uids
          })
        }.to_not change(SendPushNotificationWorker.jobs, :size).by(1)
      end
    end
  end

  context "provider is 'instagram'" do
    let(:authentication) { FactoryGirl.create(:instagram_authentication) }
    let(:number_of_connected_uids) { rand(2..6) }
    let(:number_of_not_connected_uids) { rand(2..6) }
    let(:stubbed_uids) do
      _stubbed_uids = []
      number_of_connected_uids.times { _stubbed_uids << FactoryGirl.create(:instagram_authentication).uid }
      number_of_not_connected_uids.times { _stubbed_uids << "instauid_#{Faker::Number.number(10)}" }
      _stubbed_uids
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should follow Users matching the UIDs for user' do
      call_service({
        authentication: authentication,
        uids: stubbed_uids
      })

      expect_service_success
      expect(service_response.count).to eq(number_of_connected_uids)
      expect(authentication.user.reload.followed_user_count).to eq(number_of_connected_uids)
    end
  end

  context "provider is 'twitter'" do
    let(:authentication) { FactoryGirl.create(:twitter_authentication) }
    let(:number_of_connected_uids) { rand(2..6) }
    let(:number_of_not_connected_uids) { rand(2..6) }
    let(:stubbed_uids) do
      _stubbed_uids = []
      number_of_connected_uids.times { _stubbed_uids << FactoryGirl.create(:twitter_authentication).uid }
      number_of_not_connected_uids.times { _stubbed_uids << "tuid_#{Faker::Number.number(10)}" }
      _stubbed_uids
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should follow Users matching the UIDs for user' do
      call_service({
        authentication: authentication,
        uids: stubbed_uids
      })

      expect_service_success
      expect(service_response.count).to eq(number_of_connected_uids)
      expect(authentication.user.reload.followed_user_count).to eq(number_of_connected_uids)
    end
  end
end
