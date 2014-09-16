require 'spec_helper'

describe FetchSocialConnectionUids do
  let(:service_class) { FetchSocialConnectionUids }

  context "provider is 'facebook'" do
    let(:authentication) { FactoryGirl.create(:facebook_authentication) }

    context 'has an authentication' do
      subject(:facebook_authenticated_user) { FacebookAuthenticatedUserDecorator.new(FactoryGirl.create(:user, :with_facebook_authentication)) }
      let(:number_of_connections) { rand(2..6) }
      let(:stubbed_connections) do
        _stubbed_connections = []
        number_of_connections.times { _stubbed_connections << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
        _stubbed_connections
      end

      it 'should return an array of UIDs for connections from that authentication' do
        stub_facebook_client(connections: stubbed_connections)

        call_service({
          authentication: authentication,
          user: facebook_authenticated_user
        })

        expect_service_success
        expect(service_response.count).to eq(number_of_connections)
        expect(service_response).to eq(stubbed_connections.map { |c| c['id']} )
      end
    end
  end
end
