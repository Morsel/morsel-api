require 'spec_helper'

describe 'Users API' do
  describe 'GET /users/me users#me' do
    let(:user) { FactoryGirl.create(:user) }

    it 'returns the authenticated User' do
      get '/users/me', api_key: api_key_for_user(user), format: :json

      expect(response).to be_success

      expect(json_data['id']).to eq(user.id)
    end

    context 'invalid api_key' do
      it 'returns an unauthorized error' do
        get '/users/me', api_key: '1:234567890', format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /users/checkusername users#checkusername' do
    let(:user) { FactoryGirl.create(:user) }

    it 'returns true if the username does exist' do
      get '/users/checkusername', username: user.username, format: :json

      expect(response).to be_success

      expect(json_data).to eq('true')
    end

    it 'returns false if the username does NOT exist' do
      get '/users/checkusername', username: 'not_a_username', format: :json

      expect(response).to be_success

      expect(json_data).to eq('false')
    end

    it 'can also accept username in the URL' do
      get "/users/checkusername/#{user.username}", format: :json

      expect(response).to be_success

      expect(json_data).to eq('true')
    end

    it 'ignores case' do
      get '/users/checkusername', username: user.username.swapcase, format: :json

      expect(response).to be_success

      expect(json_data).to eq('true')
    end

    context 'username is a reserved path' do
      let(:sample_reserved_path) { ReservedPaths.non_username_paths.sample }
      it 'returns true to say the username already exists' do
        get '/users/checkusername', username: sample_reserved_path, format: :json

        expect(response).to be_success

        expect(json_data).to eq('true')
      end
    end
  end

  describe 'POST /users/reserveusername users#reserveusername' do
    let(:user) { FactoryGirl.create(:user) }
    let(:fake_email) { Faker::Internet.email }
    let(:fake_username) { "user_#{Faker::Lorem.characters(10)}" }

    it 'creates a user with the specified username and email' do
      post '/users/reserveusername', email: fake_email, username: fake_username, format: :json

      expect(response).to be_success
      expect(json_data['user_id']).to_not be_nil

      user = User.find(json_data['user_id'])
      expect(user).to_not be_nil
      expect(user.email).to eq(fake_email)
      expect(user.username).to eq(fake_username)
      expect(user.active).to eq(false)
      expect(user.current_sign_in_ip).to_not be_nil
    end

    it 'sends an email' do
      expect{
        Sidekiq::Testing.inline! {
          post '/users/reserveusername', email: fake_email, username: fake_username, format: :json
        }
      }.to change(MandrillMailer.deliveries, :count).by(1)
    end

    it 'creates a user_event' do
      expect {
        post '/users/reserveusername', email: fake_email,
                                       username: fake_username,
                                       _ga: {
                                        source: 'taco'
                                       },
                                       client: {
                                        device: 'rspec',
                                        version: '1.2.3'
                                       },
                                       format: :json
      }.to change(UserEvent, :count).by(1)

      user_event = UserEvent.last
      expect(user_event.name).to eq('reserved_username')
      expect(user_event.user_id).to_not be_nil
      expect(user_event._ga['source']).to eq('taco')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end

    context 'email already registered' do
      it 'returns an error' do
        post '/users/reserveusername', email: user.email, username: fake_username, format: :json

        expect(response).to_not be_success
        expect(json_errors['email'].first).to eq('has already been taken')
      end
    end

    context 'username already registered' do
      it 'returns an error' do
        post '/users/reserveusername', email: fake_email, username: user.username, format: :json

        expect(response).to_not be_success
        expect(json_errors['username'].first).to eq('has already been taken')
      end
    end
  end

  describe 'PUT /users/:user_id/updateindustry users#updateindustry' do
    let(:user) { FactoryGirl.create(:user) }

    it 'sets the industry for the specified User' do
      put "/users/#{user.id}/updateindustry", industry: 'media', format: :json
      expect(response).to be_success
      expect(User.find(user.id).industry).to eq('media')
    end

    context 'invalid industry passed' do
      it 'throws an error' do
        put "/users/#{user.id}/updateindustry", role: 'butt', format: :json
        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /users registrations#create' do
    it 'creates a new User' do
      post '/users', format: :json, user: { email: Faker::Internet.email, password: 'password',
                                            first_name: 'Foo', last_name: 'Bar', username: "user_#{Faker::Lorem.characters(10)}",
                                            bio: 'Foo to the Stars', industry: 'diner' }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_user = User.find json_data['id']

      expect_json_keys(json_data, new_user, %w(id username first_name last_name sign_in_count title bio))
      expect(json_data['auth_token']).to eq(new_user.authentication_token)
      expect(json_data['photos']).to be_nil
      expect_nil_json_keys(json_data, %w(password encrypted_password industry))
    end

    it 'creates a user_event' do
      expect {
        post '/users', user: { email: Faker::Internet.email, password: 'password',
                        first_name: 'Foo', last_name: 'Bar', username: "user_#{Faker::Lorem.characters(10)}",
                        bio: 'Foo to the Stars'
                       },
                       _ga: {
                        source: 'grande'
                       },
                       client: {
                        device: 'rspec',
                        version: '1.2.3'
                       },
                       format: :json
      }.to change(UserEvent, :count).by(1)

      user_event = UserEvent.last
      expect(user_event.name).to eq('created_account')
      expect(user_event.user_id).to_not be_nil
      expect(user_event._ga['source']).to eq('grande')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end
  end

  describe 'POST /users/sign_in sessions#create' do
    let(:user) { FactoryGirl.create(:user) }

    it 'signs in the User' do
      post '/users/sign_in', format: :json, user: { email: user.email, password: 'password' }

      expect(response).to be_success

      expect_json_keys(json_data, user, %w(id username first_name last_name title bio))
      expect(json_data['auth_token']).to eq(user.authentication_token)
      expect(json_data['photos']).to be_nil
      expect(json_data['sign_in_count']).to eq(1)
      expect_nil_json_keys(json_data, %w(password encrypted_password))
    end
  end

  # Undocumented method
  describe 'GET /users users#index' do
    let(:users_count) { 3 }
    before do
      users_count.times { FactoryGirl.create(:user) }
    end

    it 'returns a list of Users' do
      get '/users', api_key: api_key_for_user(User.first), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(users_count)
    end
  end

  describe 'GET /users/{:user_id|user_username} users#show' do
    let(:user_with_posts) { FactoryGirl.create(:user_with_posts) }
    let(:number_of_morsel_likes) { rand(2..6) }

    before do
      morsel = user_with_posts.morsels.first
      number_of_morsel_likes.times { morsel.likers << FactoryGirl.create(:user) }
    end

    it 'returns the User' do
      get "/users/#{user_with_posts.id}", api_key: api_key_for_user(user_with_posts), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, user_with_posts, %w(id username first_name last_name sign_in_count title bio))
      expect_nil_json_keys(json_data, %w(password encrypted_password auth_token))

      expect(json_data['photos']).to be_nil
      expect(json_data['twitter_username']).to eq(user_with_posts.twitter_username)
      expect(json_data['facebook_uid']).to eq(user_with_posts.facebook_uid)

      expect(json_data['like_count']).to eq(number_of_morsel_likes)
      expect(json_data['morsel_count']).to eq(user_with_posts.morsels.count)
      expect(json_data['draft_count']).to eq(user_with_posts.posts.drafts.count)
    end

    it 'should be public' do
      get "/users/#{user_with_posts.id}", format: :json

      expect(response).to be_success
    end

    context 'username passed instead of id' do
      it 'returns the User' do
        get "/users/#{user_with_posts.username}", api_key: api_key_for_user(user_with_posts), format: :json

        expect(response).to be_success

        expect_json_keys(json_data, user_with_posts, %w(id username first_name last_name sign_in_count title bio))
        expect_nil_json_keys(json_data, %w(password encrypted_password auth_token))

        expect(json_data['photos']).to be_nil
        expect(json_data['twitter_username']).to eq(user_with_posts.twitter_username)
        expect(json_data['facebook_uid']).to eq(user_with_posts.facebook_uid)

        expect(json_data['like_count']).to eq(number_of_morsel_likes)
        expect(json_data['morsel_count']).to eq(user_with_posts.morsels.count)
      end
    end

    context 'has a photo' do
      before do
        user_with_posts.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
        user_with_posts.save
      end

      it 'returns the User with the appropriate image sizes' do
        get "/users/#{user_with_posts.id}", api_key: api_key_for_user(user_with_posts), format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_144x144']).to_not be_nil
        expect(photos['_72x72']).to_not be_nil
        expect(photos['_80x80']).to_not be_nil
        expect(photos['_40x40']).to_not be_nil
      end
    end

    context 'has a Post draft' do
      before do
        user_with_posts.posts.first.update(draft: true)
      end

      it 'returns 1 for draft_count' do
        get "/users/#{user_with_posts.id}", api_key: api_key_for_user(user_with_posts), format: :json

        expect(response).to be_success

        expect(json_data['draft_count']).to eq(1)
      end
    end
  end

  describe 'PUT /users/{:user_id} users#update' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put "/users/#{turd_ferg.id}", api_key: api_key_for_user(turd_ferg), format: :json, user: { first_name: new_first_name }

      expect(response).to be_success

      expect(json_data['first_name']).to eq(new_first_name)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /users/{:user_id|user_username}/posts' do
    let(:posts_count) { 3 }
    let(:user_with_posts) { FactoryGirl.create(:user_with_posts, posts_count: posts_count) }
    let(:endpoint) { "/users/#{user_with_posts.id}/posts" }

    it_behaves_like 'TimelinePaginateable' do
      let(:user) { FactoryGirl.create(:user_with_posts) }
      let(:paginateable_object_class) { Post }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:post_with_creator, creator: user_with_posts) }
      end
    end

    it 'returns all of the User\'s  Posts' do
      get endpoint, api_key: api_key_for_user(user_with_posts), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(user_with_posts.posts.count)
    end

    context 'has drafts' do
      let(:draft_posts_count) { rand(3..6) }
      before do
        draft_posts_count.times { FactoryGirl.create(:draft_post_with_morsels, creator: user_with_posts) }
      end

      it 'should NOT include drafts' do
        get endpoint, api_key: api_key_for_user(user_with_posts),
                                                  format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(posts_count)
      end

      context 'include_drafts=true' do
        it 'should include drafts' do
          get endpoint, api_key: api_key_for_user(user_with_posts),
                                                    include_drafts: true,
                                                    format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(posts_count + draft_posts_count)
        end
      end
    end

    context 'username passed instead of id' do
      it 'returns all of the User\'s  Posts' do
        get "/users/#{user_with_posts.username}/posts", api_key: api_key_for_user(user_with_posts), format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(user_with_posts.posts.count)
      end
    end
  end

  describe 'GET /users/authorizations' do
    let(:endpoint) { '/users/authorizations' }
    let(:user) { FactoryGirl.create(:user) }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Authorization }
      before do
        paginateable_object_class.delete_all
        15.times { FactoryGirl.create(:facebook_authorization, user: user) }
        15.times { FactoryGirl.create(:twitter_authorization, user: user) }
      end
    end

    it 'returns the current_user\'s Authorizations' do
      get "/users/authorizations", api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
    end
  end

  describe 'POST /users/authorizations' do
    let(:chef) { FactoryGirl.create(:chef) }

    context 'Twitter' do
      it 'creates a new Twitter authorization' do
        dummy_screen_name = 'twitter_screen_name'
        dummy_secret = 'secret'
        dummy_token = 'token'
        client = double('Twitter::REST::Client')
        twitter_user = double('Twitter::User')
        Twitter::Client.stub(:new).and_return(client)
        client.stub(:current_user).and_return(twitter_user)
        twitter_user.stub(:id).and_return(123)
        twitter_user.stub(:screen_name).and_return(dummy_screen_name)
        twitter_user.stub(:url).and_return("https://twitter.com/#{dummy_screen_name}")

        post '/users/authorizations', api_key: api_key_for_user(chef),
                                      provider: 'twitter',
                                      token: dummy_token,
                                      secret: dummy_secret,
                                      format: :json

        expect(response).to be_success

        expect(json_data['id']).to_not eq(123)
        expect(json_data['provider']).to eq('twitter')
        expect(json_data['secret']).to eq(dummy_secret)
        expect(json_data['token']).to eq(dummy_token)
        expect(json_data['user_id']).to eq(chef.id)
        expect(json_data['name']).to eq(dummy_screen_name)

        expect(chef.twitter_authorizations.count).to eq(1)
        expect(chef.twitter_username).to eq(dummy_screen_name)
      end
    end

    context 'Facebook' do
      it 'creates a new Facebook authorization' do
        dummy_name = 'Facebook User'
        dummy_token = 'token'
        dummy_fb_uid = '123456'
        client = double('Koala::Facebook::API')
        Koala::Facebook::API.stub(:new).and_return(client)
        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return(dummy_fb_uid)
        facebook_user.stub(:[]).with('name').and_return(dummy_name)
        facebook_user.stub(:[]).with('link').and_return("https://facebook.com/#{dummy_name}")

        client.stub(:get_object).and_return(facebook_user)

        post '/users/authorizations', api_key: api_key_for_user(chef),
                                      provider: 'facebook',
                                      token: dummy_token,
                                      format: :json

        expect(response).to be_success

        expect(json_data['uid']).to eq(dummy_fb_uid)
        expect(json_data['provider']).to eq('facebook')
        expect(json_data['secret']).to be_nil
        expect(json_data['token']).to eq(dummy_token)
        expect(json_data['user_id']).to eq(chef.id)
        expect(json_data['name']).to eq(dummy_name)

        expect(chef.facebook_authorizations.count).to eq(1)
        expect(chef.facebook_uid).to eq(dummy_fb_uid)
      end
    end
  end

  describe 'GET /users/unsubscribe users#unsubscribe' do
    let(:user) { FactoryGirl.create(:user) }

    it 'unsubscribes the user' do
      expect(user.unsubscribed).to be_false
      post '/users/unsubscribe', email: user.email
      expect(response).to be_success
      user.reload
      expect(user.unsubscribed).to be_true
    end
  end

  describe 'GET /users/activities' do
    let(:endpoint) { '/users/activities' }
    let(:user) { FactoryGirl.create(:user) }
    let(:morsels_count) { 3 }
    let(:some_post) { FactoryGirl.create(:post_with_morsels, morsels_count: morsels_count) }

    before do
      some_post.morsels.each do |morsel|
        Sidekiq::Testing.inline! { morsel.likers << user }
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Activity }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:morsel_like_activity, creator_id: user.id) }
      end
    end

    it 'returns the User\'s recent activities' do
      get endpoint, api_key: api_key_for_user(user), format: :json
      expect(response).to be_success
      expect(json_data.count).to eq(morsels_count)
      first_activity = json_data.first
      expect(first_activity['action_type']).to eq('Like')
      expect(first_activity['subject_type']).to eq('Morsel')

      # Since the activities call returns the newest first, compare against the last Morsel in some_post
      expect_json_keys(first_activity['subject'], some_post.morsels.last, %w(id description nonce))
    end

    context 'subject is deleted' do
      before do
        Like.last.destroy
      end

      it 'removes the Activity' do
        get endpoint, api_key: api_key_for_user(user),
                 format: :json
        expect(response).to be_success
        expect(json_data.count).to eq(morsels_count - 1)
      end
    end
  end

  describe 'GET /users/notifications' do
    let(:endpoint) { '/users/notifications' }
    let(:user) { FactoryGirl.create(:user) }
    let(:last_user) { FactoryGirl.create(:user) }
    let(:notifications_count) { 3 }
    let(:some_post) { FactoryGirl.create(:post_with_creator, creator: user) }

    context 'a Morsel is liked' do
      before do
        notifications_count.times { FactoryGirl.create(:morsel_with_creator, creator: user, post:some_post) }
        user.morsels.each do |morsel|
          Sidekiq::Testing.inline! { morsel.likers << FactoryGirl.create(:user) }
        end
        Sidekiq::Testing.inline! { user.morsels.last.likers << last_user }
      end

      it 'returns the User\'s recent notifications' do
        get endpoint, api_key: api_key_for_user(user), format: :json
        expect(response).to be_success
        expect(json_data.count).to eq(notifications_count + 1)
        first_notification = json_data.first
        first_morsel = some_post.morsels.first

        expect(first_notification['message']).to eq("#{last_user.full_name} (#{last_user.username}) liked #{first_morsel.post_title_with_description}".truncate(100, separator: ' ', omission: '... '))
        expect(first_notification['payload_type']).to eq('Activity')
        expect(first_notification['payload']['action_type']).to eq('Like')
        expect(first_notification['payload']['subject_type']).to eq('Morsel')

        # Since the notifications call returns the newest first, compare against the last Morsel in some_post
        expect_json_keys(first_notification['payload']['subject'], first_morsel, %w(id description nonce))
      end

      context 'Morsel is unliked' do
        before do
          Like.last.destroy
        end

        it 'should not notify for that action' do
          get endpoint, api_key: api_key_for_user(user), format: :json
          expect(response).to be_success
          expect(json_data.count).to eq(notifications_count)
        end
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Notification }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:activity_notification, user: user) }
      end
    end
  end
end
