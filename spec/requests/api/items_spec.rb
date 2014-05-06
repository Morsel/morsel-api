require 'spec_helper'

describe 'Items API' do
  describe 'POST /items items#create' do
    let(:endpoint) { '/items' }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:nonce) { '1234567890-1234-1234-1234-1234567890123' }
    let(:morsel) { FactoryGirl.create(:morsel_with_creator) }

    it 'creates an Item' do
      post_endpoint item: {
                      description: 'It\'s not a toomarh!',
                      photo: test_photo,
                      nonce: nonce,
                      morsel_id: morsel.id
                    }

      expect_success
      expect(json_data['id']).to_not be_nil
      expect(json_data['photos']).to_not be_nil

      new_item = Item.find json_data['id']
      expect_json_keys(json_data, new_item, %w(id description creator_id))
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
      it 'should NOT be authorized' do
        post_endpoint item: {
                        description: 'Holy Diver',
                        nonce: nonce,
                        morsel_id: morsel.id
                      }

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /items/{:item_id} items#show' do
    let(:endpoint) { "/items/#{item.id}" }
    let(:item) { FactoryGirl.create(:item_with_creator_and_morsel) }

    context 'authenticated and current_user likes the Item' do
      let(:current_user) { FactoryGirl.create(:user) }
      before { Like.create(likeable: item, liker: current_user) }

      it 'returns liked=true' do
        get_endpoint

        expect_success
        expect(json_data['liked']).to be_true
      end
    end

    it 'returns the Item' do
      get_endpoint

      expect_success
      expect_json_keys(json_data, item, %w(id description creator_id))
      expect(json_data['liked']).to be_false
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

  describe 'PUT /items/{:item_id} items#update' do
    let(:endpoint) { "/items/#{item.id}" }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:item) { FactoryGirl.create(:item_with_creator_and_morsel, creator: current_user) }
    let(:new_description) { 'The proof is in the puddin' }

    it 'updates the Item' do
      put_endpoint  item: {
                      description: new_description
                    }

      expect_success
      expect(json_data['description']).to eq(new_description)
      expect(Item.find(item.id).description).to eq(new_description)
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

  describe 'POST /items/{:item_id}/like' do
    let(:endpoint) { "/items/#{item.id}/like" }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }

      it 'likes the Item' do
        post_endpoint

        expect_success
        expect(item.likers).to include(current_user)
      end

      it 'creates an Activity and Notification' do
        Sidekiq::Testing.inline! { post_endpoint }

        expect_success

        activity = current_user.activities.last
        expect(activity).to_not be_nil
        expect(activity.creator).to eq(current_user)
        expect(activity.recipient).to eq(item.creator)
        expect(activity.subject).to eq(item)
        expect(activity.action).to eq(Like.last)

        notification = item.creator.notifications.last
        expect(notification).to_not be_nil
        expect(notification.user).to eq(item.creator)
        expect(notification.payload).to eq(activity)
        expect(notification.message).to eq("#{current_user.full_name} (#{current_user.username}) liked #{item.morsel_title_with_description}".truncate(100, separator: ' ', omission: '... '))
      end

      context 'already likes the Item' do
        before { item.likers << current_user }

        it 'returns an error' do
          post_endpoint

          expect_failure
          expect(response.status).to eq(422)
          expect(json_errors['item'].first).to eq('already liked')
        end
      end

      context 'liked then unliked the Item' do
        before do
          item.likers << current_user
          item.likers.destroy(current_user)
        end

        it 'likes the Item for the current_user' do
          post_endpoint

          expect_success
          expect(response.status).to eq(201)
          expect(item.likers).to include(current_user)
        end
      end
    end
  end

  describe 'DELETE /items/{:item_id}/like likes#destroy' do
    let(:endpoint) { "/items/#{item.id}/like" }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }

      context 'current_user has liked Item' do
        before { Like.create(likeable: item, user: current_user) }

        it 'soft deletes the Like' do
          delete_endpoint

          expect_success
          expect(item.likers).to_not include(current_user)
        end
      end

      context 'current_user has NOT liked Item' do
        it 'does NOT soft delete the Like' do
          delete_endpoint

          expect_failure
          expect(response.status).to eq(422)
          expect(json_errors['item'].first).to eq('not liked')
        end
      end

      context 'current_user is NOT Like creator' do
        before { Like.create(likeable: item, user: FactoryGirl.create(:user)) }
        it 'should NOT be authorized' do
          delete_endpoint

          expect_failure
        end
      end
    end
  end

  describe 'GET /items/{:item_id}/likers items#likers' do
    let(:endpoint) { "/items/#{item.id}/likers" }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    # HACK: TimelinePaginateable specs won't pass without this.
    before { 1.times { FactoryGirl.create(:item_like, likeable: item) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_like, likeable: item) }
      end
    end
  end

  describe 'GET /items/{:item_id}/comments comments#index' do
    let(:endpoint) { "/items/#{item.id}/comments" }
    let(:item) { FactoryGirl.create(:item_with_creator_and_comments, comments_count: comments_count) }
    let(:comments_count) { 2 }

    it 'returns a list of Comments for the Item' do
      get_endpoint

      expect_success
      expect(json_data.count).to eq(comments_count)

      first_comment = json_data.first
      expect(first_comment['creator']).to_not be_nil
      expect(first_comment['commentable_id']).to eq(item.id)
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Comment }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_comment, commentable: item) }
      end
    end
  end

  describe 'POST /items/{:item_id}/comments comments#create' do
    let(:endpoint) { "/items/#{item.id}/comments" }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:item) { FactoryGirl.create(:item_with_creator) }

    it 'creates a Comment for the Item' do
      post_endpoint comment: {
                      description: 'Drop it like it\'s hot.'
                    }

      expect_success
      expect(json_data['id']).to_not be_nil

      new_comment = Comment.find(json_data['id'])
      expect_json_keys(json_data, new_comment, %w(id description))
      expect(json_data['creator']).to_not be_nil
      expect(json_data['creator']['id']).to eq(current_user.id)
      expect(json_data['commentable_id']).to eq(new_comment.commentable.id)
      expect(current_user.has_role?(:creator, new_comment))
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post_endpoint comment: {
                        description: 'Drop it like it\'s hot.'
                      }
      end

      expect_success

      activity = current_user.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(current_user)
      expect(activity.recipient).to eq(item.creator)
      expect(activity.subject).to eq(item)
      expect(activity.action).to eq(Comment.last)

      notification = item.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(item.creator)
      expect(notification.payload).to eq(activity)
      expect(notification.message).to eq("#{current_user.full_name} (#{current_user.username}) commented on #{item.morsel_title_with_description}".truncate(100, separator: ' ', omission: '... '))
    end

    context 'missing Item' do
      let(:endpoint) { "/items/0/comments" }
      it 'should fail' do
        post_endpoint comment: {
                        description: 'Drop it like it\'s hot.'
                      }

        expect_failure
      end
    end

    context 'current_user is NOT a :chef' do
      let(:current_user) { FactoryGirl.create(:user) }
      it 'should NOT be authorized' do
        post_endpoint comment: {
                        description: 'Drop it like it\'s hot.'
                      }

        expect_failure
      end
    end
  end

  describe 'DELETE /comments/{:comment_id} comments#destroy' do
    let(:item) { FactoryGirl.create(:item_with_creator) }

    context 'current_user is the Comment creator' do
      let(:endpoint) { "/items/#{item.id}/comments/#{comment.id}" }
      let(:current_user) { FactoryGirl.create(:chef) }
      let(:comment) { FactoryGirl.create(:item_comment, user: current_user) }

      it 'soft deletes the Comment' do
        delete_endpoint
        expect_success
        expect(Comment.find_by(id: comment.id)).to be_nil
      end
    end

    context 'current_user is the Item creator' do
      let(:endpoint) { "/items/#{item.id}/comments/#{comment.id}" }
      let(:current_user) { FactoryGirl.create(:chef) }
      let(:comment) { FactoryGirl.create(:item_comment, commentable: FactoryGirl.create(:item, creator: current_user)) }

      it 'soft deletes the Comment' do
        delete_endpoint

        expect_success
        expect(Comment.find_by(id: comment.id)).to be_nil
      end
    end

    context 'current_user is not the Comment or Item creator' do
      let(:endpoint) { "/items/#{item.id}/comments/#{comment.id}" }
      let(:current_user) { FactoryGirl.create(:chef) }
      let(:comment) { FactoryGirl.create(:item_comment) }

      it 'does NOT soft delete the Comment' do
        delete_endpoint

        expect_failure
        expect(Comment.find_by(id: comment.id)).to_not be_nil
        expect(json_errors['api'].first).to eq('Not authorized to delete Comment')
      end
    end
  end
end
