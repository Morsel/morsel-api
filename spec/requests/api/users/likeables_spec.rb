require_relative '_spec_helper'

describe 'GET /users/:id/likeables' do
  context 'type=Item' do
    let(:endpoint) { "/users/#{liker.id}/likeables?type=Item" }
    let(:liker) { FactoryGirl.create(:user) }
    let(:liked_item_count) { rand(2..6) }

    before { liked_item_count.times { FactoryGirl.create(:item_like, liker: liker, likeable: FactoryGirl.create(:item_with_creator_and_morsel)) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Item }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_like, liker: liker, likeable: FactoryGirl.create(:item_with_creator_and_morsel)) }
      end
    end

    it 'returns the Items that the User has liked' do
      get_endpoint

      expect_success
      expect_json_data_count liked_item_count
      expect_first_json_data_eq('liked_at' => Like.last.created_at.as_json)
    end
  end
end
