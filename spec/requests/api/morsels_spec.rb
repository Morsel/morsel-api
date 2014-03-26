require 'spec_helper'

describe 'Morsels API' do
  let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
  let(:chef) { FactoryGirl.create(:chef) }
  let(:morsels_count) { 4 }

  describe 'POST /morsels morsels#create' do
    let(:chef) { FactoryGirl.create(:chef) }
    let(:nonce) { '1234567890-1234-1234-1234-1234567890123' }
    let(:some_post) { FactoryGirl.create(:post) }

    it 'creates a Morsel' do
      post '/morsels',  api_key: api_key_for_user(chef),
                        format: :json,
                        morsel: {
                          description: 'It\'s not a toomarh!',
                          photo: Rack::Test::UploadedFile.new(
                            File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                          nonce: nonce,
                          post: {
                            id: some_post.id
                          }
                        }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_morsel = Morsel.find json_data['id']
      expect_json_keys(json_data, new_morsel, %w(id description creator_id))
      expect(json_data['photos']).to_not be_nil

      expect(new_morsel.post).to eq(some_post)
      expect(new_morsel.nonce).to eq(nonce)
    end

    context 'deprecated parameters' do
      describe 'post_id' do
        it 'creates a Morsel' do
          post '/morsels',  api_key: api_key_for_user(chef),
                            format: :json,
                            morsel: {
                              description: 'It\'s not a toomarh!',
                              photo: Rack::Test::UploadedFile.new(
                                File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                              nonce: nonce
                            },
                            post_id: some_post.id

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          new_morsel = Morsel.find json_data['id']
          expect_json_keys(json_data, new_morsel, %w(id description creator_id))
          expect(json_data['photos']).to_not be_nil

          expect(new_morsel.post).to eq(some_post)
          expect(new_morsel.nonce).to eq(nonce)
        end
      end

      describe 'post_title' do
        let(:expected_title) { 'Symphony of Destruction' }
        it 'changes the post_title' do
          post '/morsels',  api_key: api_key_for_user(chef),
                            format: :json,
                            morsel: { description: 'Explooooooooooooooodes-aaah' },
                            post_id: some_post.id,
                            post_title: expected_title

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          new_morsel = Morsel.find json_data['id']
          expect(new_morsel.post.title).to eq(expected_title)
        end
      end

      describe 'sort_order' do
        let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }
        let(:expected_sort_order) { 2 }
        it 'changes the sort_order' do
          post '/morsels',  api_key: api_key_for_user(chef),
                            format: :json,
                            morsel: { description: 'Explooooooooooooooodes-aaah' },
                            post_id: post_with_morsels.id,
                            sort_order: expected_sort_order

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          new_morsel = Morsel.find json_data['id']
          expect(new_morsel.sort_order).to eq(expected_sort_order)
        end
      end
    end

    context 'sort_order included in parameters' do
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels) }

      it 'changes the sort_order' do
        post '/morsels',  api_key: api_key_for_user(chef),
                          format: :json,
                          morsel: {
                            description: 'Parabol.',
                            sort_order: 1,
                            post: {
                              id: post_with_morsels.id
                            }
                          }

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

        expect(post_with_morsels.morsel_ids.first).to eq(json_data['id'])
      end

      describe '213 sort_order scenario' do
        context 'Morsels are created and attached to the same Post with sort_orders 2,1,3' do
          let(:existing_post) { FactoryGirl.create(:post_with_creator) }
          let(:descriptions) { [ 'Should be first', 'Should be second', 'Should be third'] }

          before do
            post '/morsels',  api_key: api_key_for_user(chef),
                              format: :json,
                              morsel: {
                                description: descriptions[1],
                                sort_order: 2,
                                post: {
                                  id: existing_post.id
                                }
                              }

            post '/morsels',  api_key: api_key_for_user(chef),
                              format: :json,
                              morsel: {
                                description: descriptions[0],
                                sort_order: 1,
                                post: {
                                  id: existing_post.id
                                }
                              }

            post '/morsels',  api_key: api_key_for_user(chef),
                              format: :json,
                              morsel: {
                                description: descriptions[2],
                                sort_order: 3,
                                post: {
                                  id: existing_post.id
                                }
                              }

          end
          it 'returns them in the correct order' do
            expect(existing_post.morsels.map { |m| m.sort_order }).to eq([1, 2, 3])
            expect(existing_post.morsels.map { |m| m.description }).to eq(descriptions)
          end
        end

      end
    end

    context 'post_to_facebook included in parameters' do
      let(:chef_with_facebook_authorization) { FactoryGirl.create(:chef_with_facebook_authorization) }

      it 'posts to Facebook' do
        dummy_name = 'Facebook User'

        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return('12345_67890')
        facebook_user.stub(:[]).with('name').and_return(dummy_name)

        client = double('Koala::Facebook::API')

        Koala::Facebook::API.stub(:new).and_return(client)

        client.stub(:put_connections).and_return('id' => '12345_67890')

        expect {
          post '/morsels',  api_key: api_key_for_user(chef_with_facebook_authorization),
                            format: :json,
                            morsel: {
                              description: 'The Fresh Prince of Bel Air',
                              post: {
                                id: some_post.id,
                                title: 'Some title'
                              }
                            },
                            post_to_facebook: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

      end
    end

    context 'post_to_twitter included in parameters' do
      let(:chef_with_twitter_authorization) { FactoryGirl.create(:chef_with_twitter_authorization) }
      let(:expected_tweet_url) { "https://twitter.com/#{chef_with_twitter_authorization.username}/status/12345" }

      it 'posts a Tweet' do
        client = double('Twitter::REST::Client')
        tweet = double('Twitter::Tweet')
        tweet.stub(:url).and_return(expected_tweet_url)

        Twitter::Client.stub(:new).and_return(client)
        client.stub(:update).and_return(tweet)

        expect {
          post '/morsels',  api_key: api_key_for_user(chef_with_twitter_authorization),
                            format: :json,
                            morsel: {
                              description: 'D.A.N.C.E.',
                              post: {
                                id: some_post.id,
                                title: 'Some title'
                              }
                            },
                            post_to_twitter: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end

    context 'current_user is NOT a :chef' do
      it 'should NOT be authorized' do
        post '/morsels',  api_key: api_key_for_user(FactoryGirl.create(:user)),
                          format: :json,
                          morsel: {
                            description: 'Holy Diver',
                            nonce: nonce,
                            post: {
                              id: some_post.id
                            }
                          }

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /morsels morsels#show' do
    let(:morsel_with_creator) { FactoryGirl.create(:morsel_with_creator) }

    it 'returns the Morsel' do
      get "/morsels/#{morsel_with_creator.id}", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, morsel_with_creator, %w(id description creator_id))
      expect(json_data['liked']).to be_false
      expect(json_data['photos']).to_not be_nil
    end

    context 'has a photo' do
      before do
        morsel_with_creator.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
        morsel_with_creator.save
      end

      it 'returns the User with the appropriate image sizes' do
        get "/morsels/#{morsel_with_creator.id}", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_640x640']).to_not be_nil
        expect(photos['_320x320']).to_not be_nil
        expect(photos['_100x100']).to_not be_nil
        expect(photos['_50x50']).to_not be_nil
      end
    end
  end

  describe 'PUT /morsels/{:morsel_id} morsels#update' do
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator, creator: chef) }
    let(:new_description) { 'The proof is in the puddin' }

    it 'updates the Morsel' do
      put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(chef),
                                            format: :json,
                                            morsel: { description: new_description }

      expect(response).to be_success

      expect(json_data['description']).to eq(new_description)
      expect(Morsel.find(existing_morsel.id).description).to eq(new_description)
    end

    context 'current_user is NOT Morsel creator' do
      it 'should NOT be authorized' do
        put "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(FactoryGirl.create(:user)),
                                              format: :json,
                                              morsel: { description: new_description }

        expect(response).to_not be_success
      end
    end

    context 'post_id and sort_order included in parameters' do
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels, creator: chef) }
      let(:last_morsel) { post_with_morsels.morsels.last }

      context 'Morsel belongs to the Post' do
        it 'changes the sort_order' do
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(chef),
                                            format: :json,
                                            morsel: {
                                              description: 'Just like a bus route.',
                                              sort_order: 1
                                            },
                                            post_id: post_with_morsels.id

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil
          expect(post_with_morsels.morsel_ids.first).to eq(json_data['id'])
        end

        it 'touches the posts' do
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(chef),
                                            format: :json,
                                            morsel: { description: 'Just like a bus route.' },
                                            post_id: post_with_morsels.id

          expect(response).to be_success

          expect(json_data['id']).to_not be_nil

          post_with_morsels.reload
          expect(post_with_morsels.updated_at.to_datetime.to_f).to be >= last_morsel.updated_at.to_datetime.to_f
        end
      end
    end

    context 'post_to_facebook included in parameters' do
      let(:chef_with_facebook_authorization) { FactoryGirl.create(:chef_with_facebook_authorization) }
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels, creator: chef_with_facebook_authorization) }
      let(:last_morsel) { post_with_morsels.morsels.last }

      it 'posts to Facebook' do
        dummy_name = 'Facebook User'

        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return('12345_67890')
        facebook_user.stub(:[]).with('name').and_return(dummy_name)

        client = double('Koala::Facebook::API')

        Koala::Facebook::API.stub(:new).and_return(client)

        client.stub(:put_connections).and_return('id' => '12345_67890')

        expect {
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(chef_with_facebook_authorization),
                                            format: :json,
                                            morsel: {
                                              description: 'The Fresh Prince of Bel Air',
                                              post: {id: post_with_morsels.id}
                                            },
                                            post_to_facebook: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil

      end
    end

    context 'post_to_twitter included in parameters' do
      let(:chef_with_twitter_authorization) { FactoryGirl.create(:chef_with_twitter_authorization) }
      let(:expected_tweet_url) { "https://twitter.com/#{chef_with_twitter_authorization.username}/status/12345" }
      let(:post_with_morsels) { FactoryGirl.create(:post_with_morsels, creator: chef_with_twitter_authorization) }
      let(:last_morsel) { post_with_morsels.morsels.last }

      it 'posts a Tweet' do
        client = double('Twitter::REST::Client')
        tweet = double('Twitter::Tweet')
        tweet.stub(:url).and_return(expected_tweet_url)

        Twitter::Client.stub(:new).and_return(client)
        client.stub(:update).and_return(tweet)

        expect {
          put "/morsels/#{last_morsel.id}", api_key: api_key_for_user(chef_with_twitter_authorization),
                                            format: :json,
                                            morsel: {
                                              description: 'The Fresh Prince of Bel Air',
                                              post: {id: post_with_morsels.id}
                                            },
                                            post_to_twitter: true
        }.to change(SocialWorker.jobs, :size).by(1)

        expect(response).to be_success

        expect(json_data['id']).to_not be_nil
      end
    end
  end

  describe 'DELETE /morsels/{:morsel_id} morsels#destroy' do
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator, creator: chef) }

    it 'soft deletes the Morsel' do
      delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(Morsel.find_by(id: existing_morsel.id)).to be_nil
    end

    context 'current_user is NOT Morsel creator' do
      it 'should NOT be authorized' do
        delete "/morsels/#{existing_morsel.id}", api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /morsels/{:morsel_id}/like' do
    let(:morsel) { FactoryGirl.create(:morsel_with_creator) }

    it 'likes the Morsel for current_user' do
      post "/morsels/#{morsel.id}/like", api_key: api_key_for_user(chef), format: :json

      expect(response).to be_success
      expect(morsel.likers).to include(chef)
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post "/morsels/#{morsel.id}/like", api_key: api_key_for_user(chef), format: :json
      end

      expect(response).to be_success
      activity = chef.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(chef)
      expect(activity.recipient).to eq(morsel.creator)
      expect(activity.subject).to eq(morsel)
      expect(activity.action).to eq(Like.last)

      notification = morsel.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(morsel.creator)
      expect(notification.payload).to eq(activity)
      expect(notification.message).to eq("#{chef.full_name} (#{chef.username}) liked #{morsel.post_title_with_description}".truncate(100, separator: ' ', omission: '... '))
    end

    context 'current_user already likes the Morsel' do
      before do
        morsel.likers << turd_ferg
      end

      it 'returns an error' do
        post "/morsels/#{morsel.id}/like", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to_not be_success
        expect(response.status).to eq(422)
        expect(json_errors['morsel'].first).to eq('already liked')
      end
    end

    context 'current_user has liked then unliked the Morsel' do
      before do
        morsel.likers << turd_ferg
        morsel.likers.destroy(turd_ferg)
      end

      it 'likes the Morsel for the current_user' do
        post "/morsels/#{morsel.id}/like", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(response.status).to eq(200)
        expect(morsel.likers).to include(turd_ferg)
      end
    end

    context 'current_user is NOT a :chef' do
      it 'should be authorized' do
        post "/morsels/#{morsel.id}/like", api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to be_success
      end
    end

  end

  describe 'DELETE /morsels/{:morsel_id}/like likes#destroy' do
    let(:morsel) { FactoryGirl.create(:morsel_with_creator) }

    context 'current_user has liked Morsel' do
      before { Like.create(morsel: morsel, user: turd_ferg) }

      it 'soft deletes the Like' do
        delete "/morsels/#{morsel.id}/like", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success
        expect(morsel.likers).to_not include(turd_ferg)
      end
    end

    context 'current_user has NOT liked Morsel' do
      it 'does NOT soft delete the Like' do
        delete "/morsels/#{morsel.id}/like", api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to_not be_success
        expect(response.status).to eq(422)
        expect(json_errors['morsel'].first).to eq('not liked')
      end
    end

    context 'current_user is NOT Like creator' do
      before { Like.create(morsel: morsel, user: turd_ferg) }
      it 'should NOT be authorized' do
        delete "/morsels/#{morsel.id}/like", api_key: api_key_for_user(FactoryGirl.create(:user)), format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /morsels/{:morsel_id}/comments comments#index' do
    let(:morsel_with_creator_and_comments) { FactoryGirl.create(:morsel_with_creator_and_comments) }

    it 'returns a list of Comments for the Morsel' do
      get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(2)

      first_comment = json_data.first
      expect(first_comment['creator']).to_not be_nil
      expect(first_comment['morsel_id']).to eq(morsel_with_creator_and_comments.id)
    end

    it 'should be public' do
      get "/morsels/#{morsel_with_creator_and_comments.id}/comments", format: :json

      expect(response).to be_success
    end

    context 'pagination' do
      before do
        30.times do
          comment = FactoryGirl.create(:comment)
          comment.morsel = morsel_with_creator_and_comments
          comment.save
        end
      end

      describe 'max_id' do
        it 'returns results up to and including max_id' do
          expected_count = rand(3..6)
          max_id = Comment.first.id + expected_count - 1
          get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg),
                                                                          max_id: max_id,
                                                                          format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.first['id']).to eq(max_id)
        end
      end

      describe 'since_id' do
        it 'returns results since since_id' do
          expected_count = rand(3..6)
          since_id = Comment.last.id - expected_count
          get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg),
                                                                          since_id: since_id,
                                                                          format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
          expect(json_data.last['id']).to eq(since_id + 1)
        end
      end

      describe 'count' do
        it 'defaults to 20' do
          get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg),
                                                                          format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(20)
        end

        it 'limits the result' do
          expected_count = rand(3..6)
          get "/morsels/#{morsel_with_creator_and_comments.id}/comments", api_key: api_key_for_user(turd_ferg),
                                                                          count: expected_count,
                                                                          format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(expected_count)
        end
      end
    end

  end

  describe 'POST /morsels/{:morsel_id}/comments comments#create' do
    let(:existing_morsel) { FactoryGirl.create(:morsel_with_creator) }

    it 'creates a Comment for the Morsel' do
      post "/morsels/#{existing_morsel.id}/comments", api_key: api_key_for_user(chef),
                                                      format: :json,
                                                      comment: {
                                                        description: 'Drop it like it\'s hot.' }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_comment = Comment.find(json_data['id'])
      expect_json_keys(json_data, new_comment, %w(id description))

      expect(json_data['creator']).to_not be_nil
      expect(json_data['creator']['id']).to eq(chef.id)
      expect(json_data['morsel_id']).to eq(new_comment.morsel.id)
      expect(chef.has_role?(:creator, new_comment))
    end

    it 'creates an Activity and Notification' do
      Sidekiq::Testing.inline! do
        post "/morsels/#{existing_morsel.id}/comments", api_key: api_key_for_user(chef),
                                                        format: :json,
                                                        comment: {
                                                          description: 'Drop it like it\'s hot.' }
      end

      expect(response).to be_success
      activity = chef.activities.last
      expect(activity).to_not be_nil
      expect(activity.creator).to eq(chef)
      expect(activity.recipient).to eq(existing_morsel.creator)
      expect(activity.subject).to eq(existing_morsel)
      expect(activity.action).to eq(Comment.last)

      notification = existing_morsel.creator.notifications.last
      expect(notification).to_not be_nil
      expect(notification.user).to eq(existing_morsel.creator)
      expect(notification.payload).to eq(activity)
      expect(notification.message).to eq("#{chef.full_name} (#{chef.username}) commented on #{existing_morsel.post_title_with_description}".truncate(100, separator: ' ', omission: '... '))
    end

    context 'missing Morsel' do
      it 'should fail' do
        post '/morsels/0/comments', api_key: api_key_for_user(chef),
                                    format: :json,
                                    comment: {
                                      description: 'Drop it like it\'s hot.' }

        expect(response).to_not be_success
      end
    end

    context 'current_user is NOT a :chef' do
      it 'should NOT be authorized' do
        post "/morsels/#{existing_morsel.id}/comments", api_key: api_key_for_user(FactoryGirl.create(:user)),
                                                        format: :json,
                                                        comment: {
                                                          description: 'Drop it like it\'s hot.' }

        expect(response).to_not be_success
      end
    end
  end

  describe 'DELETE /comments/{:comment_id} comments#destroy' do
    context 'current_user is the Comment creator' do
      let(:comment_created_by_current_user) { FactoryGirl.create(:comment, user: chef) }

      it 'soft deletes the Comment' do
        delete "/comments/#{comment_created_by_current_user.id}", api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(Comment.find_by(id: comment_created_by_current_user.id)).to be_nil
      end
    end

    context 'current_user is the Morsel creator' do
      let(:comment_on_morsel_created_by_current_user) { FactoryGirl.create(:comment, morsel: FactoryGirl.create(:morsel, creator: chef)) }

      it 'soft deletes the Comment' do
        delete "/comments/#{comment_on_morsel_created_by_current_user.id}", api_key: api_key_for_user(chef), format: :json

        expect(response).to be_success
        expect(Comment.find_by(id: comment_on_morsel_created_by_current_user.id)).to be_nil
      end
    end

    context 'current_user is not the Comment or Morsel creator' do
      let(:comment) { FactoryGirl.create(:comment) }
      it 'does NOT soft delete the Comment' do
        delete "/comments/#{comment.id}", api_key: api_key_for_user(chef), format: :json

        expect(response).to_not be_success
        expect(Comment.find_by(id: comment.id)).to_not be_nil
        expect(json_errors['user'].first).to eq('not authorized to delete comment')
      end
    end
  end
end
