require_relative '_spec_helper'

describe 'POST /morsels/:id/tagged_users/:user_id' do
  let(:endpoint) { "/morsels/#{morsel.id}/tagged_users/#{user.id}" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  context 'current_user is the morsel creator' do
    let(:current_user) { morsel_creator }

    context 'User follows the morsel creator' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        morsel_creator.followers << user
      end

      it 'tags the User to the morsel' do
        post_endpoint

        expect_success

        expect(morsel.tagged_users).to include(user)
      end
    end

    context 'User does NOT follow the morsel creator' do
      let(:user) { FactoryGirl.create(:user) }

      it 'should return an error' do
        post_endpoint

        expect_failure

        expect_authority_error :create, MorselTaggedUser
      end
    end
  end

  context 'current_user is NOT the morsel creator' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should return an error' do
      post_endpoint

      expect_failure

      expect_authority_error :create, MorselTaggedUser
    end
  end
end

describe 'DELETE /morsels/:id/tagged_users/:user_id' do
  let(:endpoint) { "/morsels/#{morsel.id}/tagged_users/#{user.id}" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  context 'current_user is the morsel creator' do
    let(:current_user) { morsel_creator }
    let(:user) { FactoryGirl.create(:user) }

    before do
      morsel.tagged_users << user
    end

    it 'untags the User to the morsel' do
      delete_endpoint

      expect_success

      expect(morsel.tagged_users).to_not include(user)
    end
  end

  context 'current_user is NOT the morsel creator' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }

    before do
      morsel.tagged_users << user
    end

    it 'should return an error' do
      delete_endpoint

      expect_failure

      expect_authority_error :delete, MorselTaggedUser
    end
  end

  context 'User is NOT tagged to the morsel' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should return an error' do
      delete_endpoint

      expect_failure

      expect_record_not_found_error
    end
  end

end
