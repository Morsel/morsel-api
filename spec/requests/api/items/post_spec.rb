require_relative '_spec_helper'

describe 'POST /items items#create' do
  let(:endpoint) { '/items' }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:nonce) { '1234567890-1234-1234-1234-1234567890123' }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:presigned_photo_uploadable_object) {
      {
        item: {
          description: 'It\'s not a toomarh!',
          nonce: nonce,
          morsel_id: morsel.id
        }
      }
    }
    let(:endpoint_method) { :post }
  end

  it 'creates an Item' do
    Sidekiq::Testing.inline! {
      post_endpoint item: {
                      description: 'It\'s not a toomarh!',
                      photo: test_photo,
                      nonce: nonce,
                      morsel_id: morsel.id
                    }
    }

    expect_success

    new_item = Item.find json_data['id']
    expect_json_data_eq({
      'id' => new_item.id,
      'description' => new_item.description,
      'creator_id' => new_item.creator_id
    })
    # TODO: Fix this from failing
    # expect(json_data['photos']).to_not be_nil

    expect(new_item.morsel).to eq(morsel)
    expect(new_item.nonce).to eq(nonce)
  end

  context 'sort_order included in parameters' do
    let(:morsel) { FactoryGirl.create(:morsel_with_items) }

    it 'changes the sort_order' do
      post_endpoint item: {
                      description: 'Parabol.',
                      sort_order: 1,
                      morsel_id: morsel.id
                    }

      expect_success
      expect(json_data['id']).to_not be_nil
      expect(morsel.item_ids.first).to eq(json_data['id'])
    end

    describe '213 sort_order scenario' do
      context 'Items are created and attached to the same Morsel with sort_orders 2,1,3' do
        let(:new_morsel) { FactoryGirl.create(:morsel_with_creator) }
        let(:descriptions) { [ 'Should be first', 'Should be second', 'Should be third'] }

        before do
          post_endpoint item: {
                          description: descriptions[1],
                          sort_order: 2,
                          morsel_id: new_morsel.id
                        }

          post_endpoint item: {
                          description: descriptions[0],
                          sort_order: 1,
                          morsel_id: new_morsel.id
                        }

          post_endpoint item: {
                          description: descriptions[2],
                          sort_order: 3,
                          morsel_id: new_morsel.id
                        }

        end
        it 'returns them in the correct order' do
          expect(new_morsel.items.map { |m| m.sort_order }).to eq([1, 2, 3])
          expect(new_morsel.items.map { |m| m.description }).to eq(descriptions)
        end
      end
    end
  end

  context 'current_user is NOT a :chef' do
    let(:current_user) { FactoryGirl.create(:user) }
    it 'should be authorized' do
      post_endpoint item: {
                      description: 'Holy Diver',
                      nonce: nonce,
                      morsel_id: morsel.id
                    }

      expect_success
    end
  end
end
