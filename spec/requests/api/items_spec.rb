require 'spec_helper'

describe 'Items API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:chef) { FactoryGirl.create(:chef) }
  let(:items_count) { 4 }

  describe 'POST /items items#create' do
    let(:endpoint) { '/items' }
    let(:chef) { FactoryGirl.create(:chef) }
    let(:nonce) { '1234567890-1234-1234-1234-1234567890123' }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_creator) }

    it 'creates an Item' do
      post endpoint,  api_key: api_key_for_user(chef),
                        format: :json,
                        item: {
                          description: 'It\'s not a toomarh!',
                          photo: Rack::Test::UploadedFile.new(
                            File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                          nonce: nonce,
                          morsel_id: some_morsel.id
                        }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_item = Item.find json_data['id']
      expect_json_keys(json_data, new_item, %w(id description creator_id))
      expect(json_data['photos']).to_not be_nil

      expect(new_item.morsel).to eq(some_morsel)
      expect(new_item.nonce).to eq(nonce)
    end

    context 'sort_order included in parameters' do
      let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items) }

      it 'changes the sort_order' do
        post endpoint,  api_key: api_key_for_user(chef),
                          format: :json,
                          item: {
                            description: 'Parabol.',
                            sort_order: 1,
                            morsel_id: morsel_with_items.id
                          }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        expect(morsel_with_items.item_ids.first).to eq(json_data['id'])
      end

      describe '213 sort_order scenario' do
        context 'Items are created and attached to the same Morsel with sort_orders 2,1,3' do
          let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator) }
          let(:descriptions) { [ 'Should be first', 'Should be second', 'Should be third'] }

          before do
            post endpoint,  api_key: api_key_for_user(chef),
                              format: :json,
                              item: {
                                description: descriptions[1],
                                sort_order: 2,
                                morsel_id: existing_morsel.id
                              }

            post endpoint,  api_key: api_key_for_user(chef),
                              format: :json,
                              item: {
                                description: descriptions[0],
                                sort_order: 1,
                                morsel_id: existing_morsel.id
                              }

            post endpoint,  api_key: api_key_for_user(chef),
                              format: :json,
                              item: {
                                description: descriptions[2],
                                sort_order: 3,
                                morsel_id: existing_morsel.id
                              }

          end
          it 'returns them in the correct order' do
            expect(existing_morsel.items.map { |m| m.sort_order }).to eq([1, 2, 3])
            expect(existing_morsel.items.map { |m| m.description }).to eq(descriptions)
          end
        end

      end
    end

    context 'current_user is NOT a :chef' do
      it 'should NOT be authorized' do
        post endpoint,  api_key: api_key_for_user(FactoryGirl.create(:user)),
                          format: :json,
                          item: {
                            description: 'Holy Diver',
                            nonce: nonce,
                            morsel_id: some_morsel.id
                          }

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /items/{:item_id} items#show' do
    let(:endpoint) { "/items/#{item_with_creator_and_morsel.id}" }
    let(:item_with_creator_and_morsel) { FactoryGirl.create(:item_with_creator_and_morsel) }

    it 'returns the Item' do
      get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, item_with_creator_and_morsel, %w(id description creator_id))
      expect(json_data['liked']).to be_false
      expect(json_data['photos']).to_not be_nil
    end

    context 'has a photo' do
      before do
        item_with_creator_and_morsel.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
        item_with_creator_and_morsel.save
      end

      it 'returns the User with the appropriate image sizes' do
        get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_640x640']).to_not be_nil
        expect(photos['_320x320']).to_not be_nil
        expect(photos['_100x100']).to_not be_nil
        expect(photos['_50x50']).to_not be_nil
      end
    end

    it 'should be public' do
      get endpoint, format: :json

      expect(response).to be_success
    end
  end

  describe 'PUT /items/{:item_id} items#update' do
    let(:endpoint) { "/items/#{existing_item.id}" }
    let(:existing_item) { FactoryGirl.create(:item_with_creator_and_morsel, creator: chef) }
    let(:new_description) { 'The proof is in the puddin' }

    it 'updates the Item' do
      put endpoint, api_key: api_key_for_user(chef),
                                            format: :json,
                                            item: { description: new_description }

      expect(response).to be_success

      expect(json_data['description']).to eq(new_description)
      expect(Item.find(existing_item.id).description).to eq(new_description)
    end

    context 'current_user is NOT Item creator' do
      it 'should NOT be authorized' do
        put endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)),
                                              format: :json,
                                              item: { description: new_description }

        expect(response).to_not be_success
      end
    end

    context 'morsel_id and sort_order included in parameters' do
      let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, creator: chef) }
      let(:last_item) { morsel_with_items.items.last }

      context 'Item belongs to the Morsel' do
        it 'changes the sort_order' do
          put "/items/#{last_item.id}", api_key: api_key_for_user(chef),
                                            format: :json,
                                            item: {
                                              description: 'Just like a bus route.',
                                              sort_order: 1,
                                              morsel_id: morsel_with_items.id
                                            }

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil
          expect(morsel_with_items.item_ids.first).to eq(json_data['id'])
        end

        it 'touches the morsels' do
          put "/items/#{last_item.id}", api_key: api_key_for_user(chef),
                                            format: :json,
                                            item: {
                                              description: 'Just like a bus route.',
                                              morsel_id: morsel_with_items.id
                                            }

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          morsel_with_items.reload
          expect(morsel_with_items.updated_at.to_datetime.to_f).to be >= last_item.updated_at.to_datetime.to_f
        end
      end
    end
  end

  describe 'DELETE /items/{:item_id} items#destroy' do
    let(:endpoint) { "/items/#{existing_item.id}" }
    let(:existing_item) { FactoryGirl.create(:item_with_creator, creator: chef) }

    it 'soft deletes the Item' do
      delete endpoint, api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(Item.find_by(id: existing_item.id)).to be_nil
    end

    context 'current_user is NOT Item creator' do
      it 'should NOT be authorized' do
        delete endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /items/{:item_id}/like' do
    let(:endpoint) { "/items/#{item.id}/like" }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    it 'likes the Item for current_user' do
      post endpoint, api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(item.likers).to include(chef)
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post endpoint, api_key: api_key_for_user(chef), format: :json
      end

      expect(response).to be_success
      activity = chef.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(chef)
      expect(activity.recipient).to eq(item.creator)
      expect(activity.subject).to eq(item)
      expect(activity.action).to eq(Like.last)

      notification = item.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(item.creator)
      expect(notification.payload).to eq(activity)
      expect(notification.message).to eq("#{chef.full_name} (#{chef.username}) liked #{item.morsel_title_with_description}".truncate(100, separator: ' ', omission: '... '))
    end

    context 'current_user already likes the Item' do
      before do
        item.likers << turd_ferg
      end

      it 'returns an error' do
        post endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to_not be_success
        expect(response.status).to eq(422)
        expect(json_errors['item'].first).to eq('already liked')
      end
    end

    context 'current_user has liked then unliked the Item' do
      before do
        item.likers << turd_ferg
        item.likers.destroy(turd_ferg)
      end

      it 'likes the Item for the current_user' do
        post endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(response.status).to eq(201)
        expect(item.likers).to include(turd_ferg)
      end
    end

    context 'current_user is NOT a :chef' do
      it 'should be authorized' do
        post endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to be_success
      end
    end

  end

  describe 'DELETE /items/{:item_id}/like likes#destroy' do
    let(:endpoint) { "/items/#{item.id}/like" }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    context 'current_user has liked Item' do
      before { Like.create(likeable: item, user: turd_ferg) }

      it 'soft deletes the Like' do
        delete endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(item.likers).to_not include(turd_ferg)
      end
    end

    context 'current_user has NOT liked Item' do
      it 'does NOT soft delete the Like' do
        delete endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to_not be_success
        expect(response.status).to eq(422)
        expect(json_errors['item'].first).to eq('not liked')
      end
    end

    context 'current_user is NOT Like creator' do
      before { Like.create(likeable: item, user: turd_ferg) }
      it 'should NOT be authorized' do
        delete endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /items/{:item_id}/likers items#likers' do
    let(:endpoint) { "/items/#{item_id}/likers" }
    let(:likes_count) { 3 }
    let(:item_with_likers) { FactoryGirl.create(:item_with_likers, likes_count: likes_count) }
    let(:item_id) { item_with_likers.id }

    it 'returns a list of Likers for the Item' do
      get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(likes_count)
    end
  end

  describe 'GET /items/{:item_id}/comments comments#index' do
    let(:endpoint) { "/items/#{item_with_creator_and_comments.id}/comments" }
    let(:item_with_creator_and_comments) { FactoryGirl.create(:item_with_creator_and_comments) }

    it 'returns a list of Comments for the Item' do
      get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(2)

      first_comment = json_data.first
      expect(first_comment['creator']).to_not be_nil
      expect(first_comment['commentable_id']).to eq(item_with_creator_and_comments.id)
    end

    it 'should be public' do
      get endpoint, format: :json

      expect(response).to be_success
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:user) { FactoryGirl.create(:user) }
      let(:paginateable_object_class) { Comment }
      before do
        paginateable_object_class.delete_all
        30.times do
          comment = FactoryGirl.create(:item_comment)
          comment.commentable = item_with_creator_and_comments
          comment.save
        end
      end
    end
  end

  describe 'POST /items/{:item_id}/comments comments#create' do
    let(:endpoint) { "/items/#{existing_item.id}/comments" }
    let(:existing_item) { FactoryGirl.create(:item_with_creator) }

    it 'creates a Comment for the Item' do
      post endpoint, api_key: api_key_for_user(chef),
                                                      format: :json,
                                                      comment: {
                                                        description: 'Drop it like it\'s hot.' }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_comment = Comment.find(json_data['id'])
      expect_json_keys(json_data, new_comment, %w(id description))

      expect(json_data['creator']).to_not be_nil
      expect(json_data['creator']['id']).to eq(chef.id)
      expect(json_data['commentable_id']).to eq(new_comment.commentable.id)
      expect(chef.has_role?(:creator, new_comment))
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post endpoint, api_key: api_key_for_user(chef),
                                                        format: :json,
                                                        comment: {
                                                          description: 'Drop it like it\'s hot.' }
      end

      expect(response).to be_success
      activity = chef.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(chef)
      expect(activity.recipient).to eq(existing_item.creator)
      expect(activity.subject).to eq(existing_item)
      expect(activity.action).to eq(Comment.last)

      notification = existing_item.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(existing_item.creator)
      expect(notification.payload).to eq(activity)
      expect(notification.message).to eq("#{chef.full_name} (#{chef.username}) commented on #{existing_item.morsel_title_with_description}".truncate(100, separator: ' ', omission: '... '))
    end

    context 'missing Item' do
      let(:endpoint) { "/items/0/comments" }
      it 'should fail' do
        post endpoint, api_key: api_key_for_user(chef),
                                    format: :json,
                                    comment: {
                                      description: 'Drop it like it\'s hot.' }

        expect(response).to_not be_success
      end
    end

    context 'current_user is NOT a :chef' do
      it 'should NOT be authorized' do
        post endpoint, api_key: api_key_for_user(FactoryGirl.create(:user)),
                                                        format: :json,
                                                        comment: {
                                                          description: 'Drop it like it\'s hot.' }

        expect(response).to_not be_success
      end
    end
  end

  describe 'DELETE /comments/{:comment_id} comments#destroy' do
    let(:existing_item) { FactoryGirl.create(:item_with_creator) }
    context 'current_user is the Comment creator' do
      let(:endpoint) { "/items/#{existing_item.id}/comments/#{comment_created_by_current_user.id}" }
      let(:comment_created_by_current_user) { FactoryGirl.create(:item_comment, user: chef) }

      it 'soft deletes the Comment' do
        delete endpoint, api_key: api_key_for_user(chef), format: :json
        expect(response).to be_success
        expect(Comment.find_by(id: comment_created_by_current_user.id)).to be_nil
      end
    end

    context 'current_user is the Item creator' do
      let(:endpoint) { "/items/#{existing_item.id}/comments/#{comment_on_item_created_by_current_user.id}" }
      let(:comment_on_item_created_by_current_user) { FactoryGirl.create(:item_comment, commentable: FactoryGirl.create(:item, creator: chef)) }

      it 'soft deletes the Comment' do
        delete endpoint, api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(Comment.find_by(id: comment_on_item_created_by_current_user.id)).to be_nil
      end
    end

    context 'current_user is not the Comment or Item creator' do
      let(:endpoint) { "/items/#{existing_item.id}/comments/#{comment.id}" }
      let(:comment) { FactoryGirl.create(:item_comment) }

      it 'does NOT soft delete the Comment' do
        delete endpoint, api_key: api_key_for_user(chef), format: :json

        expect(response).to_not be_success
        expect(Comment.find_by(id: comment.id)).to_not be_nil
        expect(json_errors['api'].first).to eq('Not authorized to delete Comment')
      end
    end
  end
end
