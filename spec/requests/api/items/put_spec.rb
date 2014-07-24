require_relative '_spec_helper'

describe 'PUT /items/{:item_id} items#update' do
  let(:endpoint) { "/items/#{item.id}" }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:item) { FactoryGirl.create(:item_with_creator_and_morsel, creator: current_user) }
  let(:new_description) { 'The proof is in the puddin' }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:presigned_photo_uploadable_object) {
      {
        item: {
          description: new_description
        }
      }
    }
    let(:endpoint_method) { :put }
  end

  it 'updates the Item' do
    put_endpoint  item: {
                    description: new_description
                  }

    expect_success
    expect_json_data_eq('description' => new_description)
    expect(Item.find(item.id).description).to eq(new_description)
  end

  context '`prepare_presigned_upload`=true' do
    it 'should update the Item and respond with a `presigned_upload` object' do
      stub_aws_s3_client
      put_endpoint item: {
                      description: new_description
                    },
                    prepare_presigned_upload: true

      expect_success
      new_item = Item.find json_data['id']
      expect_json_data_eq({
        'id' => new_item.id,
        'description' => new_item.description,
        'creator_id' => new_item.creator_id
      })

      expect_json_eq(json_data['presigned_upload'], {
        "AWSAccessKeyId"=>"AWS_ACCESS_KEY_ID",
        "key"=> "KEY-${filename}",
        "policy"=> "POLICY",
        "signature"=>"SIGNATURE",
        "acl"=>"ACL"
      })
    end
  end

  context '`photo_key`' do
    it 'set the photo path to the new key' do
      put_endpoint  item: {
                      photo_key: "item-photos/#{item.id}/dbb6a58c-photo.jpg"
                    }

      expect_success
      expect(Item.find(item.id).photo_url.include?('dbb6a58c-photo.jpg')).to be_true
    end
  end

  context 'current_user is NOT Item creator' do
    let(:endpoint) { "/items/#{FactoryGirl.create(:item_with_creator_and_morsel).id}" }
    it 'should NOT be authorized' do
      put_endpoint  item: {
                    description: new_description
                  }

      expect_failure
    end
  end

  context 'morsel_id and sort_order included in parameters' do
    let(:endpoint) { "/items/#{last_item.id}" }
    let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, creator: current_user) }
    let(:last_item) { morsel_with_items.items.last }

    context 'Item belongs to the Morsel' do
      it 'changes the sort_order' do
        put_endpoint  item: {
                        description: 'Just like a bus route.',
                        sort_order: 1,
                        morsel_id: morsel_with_items.id
                      }

        expect_success
        expect(json_data['id']).to_not be_nil
        expect(morsel_with_items.item_ids.first).to eq(json_data['id'])
      end

      it 'touches the morsels' do
        put_endpoint  item: {
                        description: 'Just like a bus route.',
                        morsel_id: morsel_with_items.id
                      }

        expect_success
        expect(json_data['id']).to_not be_nil

        morsel_with_items.reload
        expect(morsel_with_items.updated_at.to_datetime.to_f).to be >= last_item.updated_at.to_datetime.to_f
      end
    end
  end
end
