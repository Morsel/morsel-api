require_relative '_spec_helper'

describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
  let(:current_user) { FactoryGirl.create(:chef) }

  context 'current_user\'s Morsel' do
    let(:endpoint) { "/morsels/#{morsel.id}" }
    let(:morsel) { FactoryGirl.create(:morsel_with_creator, creator: current_user) }

    it 'soft deletes the Morsel' do
      delete_endpoint

      expect_success
      expect(Morsel.find_by(id: morsel.id)).to be_nil
    end

    it 'soft deletes the Morsel\'s FeedItem' do
      delete_endpoint

      expect_success
      expect(FeedItem.find_by(subject_id: morsel.id, subject_type:morsel.class)).to be_nil
    end

    context 'with Items' do
      let(:morsel) { FactoryGirl.create(:morsel_with_items, creator: current_user) }

      it 'soft deletes all of its Items' do
        delete_endpoint

        expect_success
        expect(morsel.items).to be_empty
      end
    end
  end

  context 'someone else\'s Morsel' do
    let(:endpoint) { "/morsels/#{morsel.id}" }
    let(:morsel) { FactoryGirl.create(:morsel_with_creator, creator: FactoryGirl.create(:user)) }

    it 'should NOT be authorized' do
      delete_endpoint

      expect_failure
    end
  end
end
