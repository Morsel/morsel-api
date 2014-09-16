require 'spec_helper'

describe FollowSocialUids do
  let(:service_class) { FollowSocialUids }

  context "provider is 'facebook'" do
    let(:authentication) { FactoryGirl.create(:facebook_authentication) }

    context 'has an authentication' do
      subject(:facebook_authenticated_user) { FacebookAuthenticatedUserDecorator.new(FactoryGirl.create(:user, :with_facebook_authentication)) }
      let(:number_of_connected_uids) { rand(2..6) }
      let(:number_of_not_connected_uids) { rand(2..6) }
      let(:stubbed_uids) do
        _stubbed_uids = []
        number_of_connected_uids.times { _stubbed_uids << FactoryGirl.create(:facebook_authentication).uid }
        number_of_not_connected_uids.times { _stubbed_uids << "fbuid_#{Faker::Number.number(10)}" }
        _stubbed_uids
      end

      it 'should follow Users matching the UIDs for user' do
        call_service({
          user: facebook_authenticated_user,
          authentication: authentication,
          uids: stubbed_uids
        })

        expect_service_success
        expect(service_response.count).to eq(number_of_connected_uids)
        expect(facebook_authenticated_user.followed_user_count).to eq(number_of_connected_uids)
      end
    end
  end
end
