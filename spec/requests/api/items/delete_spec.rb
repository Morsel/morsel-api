require_relative '_spec_helper'

describe 'DELETE /items/{:item_id} items#destroy' do
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:endpoint) { "/items/#{item.id}" }

  context 'current_user\'s Item' do
    let(:item) { FactoryGirl.create(:item_with_creator, creator: current_user) }

    it 'soft deletes the Item' do
      delete_endpoint

      expect_success
      expect(Item.find_by(id: item.id)).to be_nil
    end
  end

  context 'someone else\'s Item' do
    let(:item) { FactoryGirl.create(:item_with_creator, creator: FactoryGirl.create(:user)) }

    it 'should NOT be authorized' do
      delete_endpoint

      expect_failure
    end
  end
end
