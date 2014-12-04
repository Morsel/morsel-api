require 'spec_helper'

describe Scripts::ConvertAllItemLikesToMorselLikes do
  let(:item_with_likes) { FactoryGirl.create(:item_with_likers, morsel: morsel, creator: morsel.creator, likes_count: likes_count) }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:likes_count) { rand(2..5) }

  context 'morsels not liked yet' do
    before do
      item_with_likes
      call_service
    end

    it 'should like the morsels' do
      expect_service_success
      expect(service_response).to eq([likes_count, 0])
      expect(Like.where(likeable:morsel).count).to eq(likes_count)
    end

    it 'should destroy all existing Item likes' do
      expect_service_success
      expect(Like.where(likeable:item_with_likes)).to be_empty
    end
  end

  context 'morsel already liked' do
    before do
      item_with_likes
      Like.create(liker:Like.first.liker, likeable: morsel)
      call_service
    end

    it 'should like the morsels' do
      expect_service_success
      expect(service_response).to eq([likes_count - 1, 1])
      expect(Like.where(likeable:morsel).count).to eq(likes_count)
    end

    it 'should destroy all existing Item likes' do
      expect(Like.where(likeable:item_with_likes)).to be_empty
    end
  end
end
