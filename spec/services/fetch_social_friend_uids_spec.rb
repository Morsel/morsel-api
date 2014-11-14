require 'spec_helper'

describe FetchSocialFriendUids do
  let(:service_class) { described_class }

  context "provider is 'facebook'" do
    let(:authentication) { FactoryGirl.create(:facebook_authentication) }
    let(:number_of_friends) { rand(2..6) }
    let(:stubbed_friends) do
      _stubbed_friends = []
      number_of_friends.times { _stubbed_friends << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
      _stubbed_friends
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should return an array of UIDs for friends from that authentication' do
      stub_facebook_client(friends: stubbed_friends)

      call_service({ authentication: authentication })

      expect_service_success
      expect(service_response.count).to eq(number_of_friends)
      expect(service_response).to eq(stubbed_friends.map { |c| c['id']} )
    end
  end

  context "provider is 'instagram'" do
    let(:authentication) { FactoryGirl.create(:instagram_authentication) }
    let(:number_of_friends) { rand(2..6) }
    let(:stubbed_friends) do
      _stubbed_friends = []
      number_of_friends.times { _stubbed_friends << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
      _stubbed_friends
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should return an array of UIDs for friends from that authentication' do
      stub_instagram_client(friends: stubbed_friends)

      call_service({ authentication: authentication })

      expect_service_success
      expect(service_response.count).to eq(number_of_friends)
      expect(service_response).to eq(stubbed_friends.map { |c| c['id']} )
    end
  end

  context "provider is 'twitter'" do
    let(:authentication) { FactoryGirl.create(:twitter_authentication) }
    let(:number_of_friends) { rand(2..6) }
    let(:stubbed_friends) do
      _stubbed_friends = []
      number_of_friends.times { _stubbed_friends << Faker::Number.number(rand(5..10)) }
      _stubbed_friends
    end

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        authentication: authentication
      }}
    end

    it 'should return an array of UIDs for friends from that authentication' do
      stub_twitter_client(friends: stubbed_friends)

      call_service({ authentication: authentication })

      expect_service_success
      expect(service_response.count).to eq(number_of_friends)
      expect(service_response).to eq(stubbed_friends)
    end
  end
end
