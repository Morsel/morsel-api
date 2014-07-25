require_relative '_spec_helper'

describe 'GET /items/{:item_id} items#show' do
  let(:endpoint) { "/items/#{item.id}" }
  let(:item) { FactoryGirl.create(:item_with_creator_and_morsel) }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:current_user) { item.creator }
    let(:presigned_photo_uploadable_object) {
      {
        api_key: api_key_for_user(current_user)
      }
    }
    let(:endpoint_method) { :get }
  end

  context 'authenticated and current_user likes the Item' do
    let(:current_user) { FactoryGirl.create(:user) }
    before { Like.create(likeable: item, liker: current_user) }

    it 'returns liked=true' do
      get_endpoint

      expect_success
      expect_json_data_eq('liked' => true)
    end
  end

  it 'returns the Item' do
    get_endpoint

    expect_success
    expect_json_data_eq({
      'id' => item.id,
      'description' => item.description,
      'creator_id' => item.creator_id,
      'liked' => false
    })
    expect(json_data['photos']).to_not be_nil
  end

  context 'has a photo' do
    before { item.update(photo: test_photo) }

    it 'returns the User with the appropriate image sizes' do
      get_endpoint

      expect_success

      photos = json_data['photos']
      expect(photos['_640x640']).to_not be_nil
      expect(photos['_320x320']).to_not be_nil
      expect(photos['_100x100']).to_not be_nil
      expect(photos['_50x50']).to_not be_nil
    end
  end
end
