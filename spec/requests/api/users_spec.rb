require 'spec_helper'

describe 'Users API' do
  it_behaves_like 'TaggableController' do
    let(:user) { FactoryGirl.create(:chef) }
    let(:taggable_route) { '/users' }
    let(:taggable) { user }
    let(:keyword) { FactoryGirl.create(:keyword) }
    let(:tag) { FactoryGirl.create(:user_tag, tagger: user) }
  end

  describe 'GET /users/me users#me' do
    let(:endpoint) { '/users/me' }
    let(:user) { FactoryGirl.create(:user) }

    it 'returns the authenticated User' do
      get endpoint, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, user, %w(id username first_name last_name sign_in_count bio staff email))
    end

    context 'has a Morsel draft' do
      let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
      before do
        user_with_morsels.morsels.first.update(draft: true)
      end

      it 'returns 1 for draft_count' do
        get endpoint, api_key: api_key_for_user(user_with_morsels), format: :json

        expect(response).to be_success

        expect(json_data['draft_count']).to eq(1)
      end
    end

    context 'invalid api_key' do
      it 'returns an unauthorized error' do
        get endpoint, api_key: '1:234567890', format: :json

        expect(response).to_not be_success
      end
    end
  end

  describe 'GET /users/validateusername users#validateusername' do
    let(:endpoint) { '/users/validateusername' }
    let(:user) { FactoryGirl.create(:user) }
    it 'returns true if the username does NOT exist' do
      get endpoint, username: 'not_a_username', format: :json

      expect(response).to be_success

      expect(json_data).to eq(true)
    end

    it 'returns an error if the username is nil' do
      get endpoint, format: :json

      expect(response).to_not be_success
      expect(json_errors['username']).to include('is required')
    end

    it 'returns an error if the username is too long' do
      get endpoint, username: 'longlonglonglong', format: :json

      expect(response).to_not be_success
      expect(json_errors['username']).to include('must be less than 16 characters')
    end

    it 'returns an error for spaces' do
      get endpoint, username: 'Bob Dole', format: :json

      expect(response).to_not be_success
      expect(json_errors['username']).to include('cannot contain spaces')
    end

    it 'returns an error if the username already exists' do
      get endpoint, username: user.username, format: :json

      expect(response).to_not be_success
      expect(json_errors['username']).to include('has already been taken')
    end

    it 'ignores case' do
      get endpoint, username: user.username.swapcase, format: :json

      expect(response).to_not be_success
      expect(json_errors['username']).to include('has already been taken')
    end

    context 'username is a reserved path' do
      let(:sample_reserved_path) { ReservedPaths.non_username_paths.sample }
      it 'returns true to say the username already exists' do
        get endpoint, username: sample_reserved_path, format: :json

        expect(response).to_not be_success
        expect(json_errors['username']).to include('has already been taken')
      end
    end
  end

  describe 'POST /users/reserveusername users#reserveusername' do
    let(:endpoint) { '/users/reserveusername' }
    let(:user) { FactoryGirl.create(:user) }
    let(:fake_email) { Faker::Internet.email }
    let(:fake_username) { "user_#{Faker::Lorem.characters(10)}" }

    it 'creates a user with the specified username and email' do
      post endpoint,  user: {
                                        email: fake_email,
                                        username: fake_username
                                      },
                                      format: :json

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
          post endpoint,  user: {
                                            email: fake_email,
                                            username: fake_username
                                          },
                                          format: :json
        }
      }.to change(MandrillMailer.deliveries, :count).by(1)
    end

    it 'creates a user_event' do
      expect {
        post endpoint,  user: {
                                          email: fake_email,
                                          username: fake_username
                                        },
                                        __utmz: 'source=taco',
                                        client: {
                                          device: 'rspec',
                                          version: '1.2.3'
                                        },
                                        format: :json
      }.to change(UserEvent, :count).by(1)

      user_event = UserEvent.last
      expect(user_event.name).to eq('reserved_username')
      expect(user_event.user_id).to_not be_nil
      expect(user_event.__utmz).to eq('source=taco')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end

    context 'email already registered' do
      it 'returns an error' do
        post endpoint,  user: {
                                          email: user.email,
                                          username: fake_username
                                        },
                                        format: :json

        expect(response).to_not be_success
        expect(json_errors['email'].first).to eq('has already been taken')
      end
    end

    context 'username already registered' do
      it 'returns an error' do
        post endpoint,  user: {
                                          email: fake_email,
                                          username: user.username
                                        },
                                        format: :json

        expect(response).to_not be_success
        expect(json_errors['username'].first).to eq('has already been taken')
      end
    end
  end

  describe 'PUT /users/:user_id/updateindustry users#updateindustry' do
    let(:endpoint) { "/users/#{user.id}/updateindustry" }
    let(:user) { FactoryGirl.create(:user) }

    it 'sets the industry for the specified User' do
      put endpoint, user: { industry: 'media' }, format: :json
      expect(response).to be_success
      expect(User.find(user.id).industry).to eq('media')
    end

    context 'invalid industry passed' do
      it 'throws an error' do
        put endpoint, user: { industry: 'butt' }, format: :json
        expect(response).to_not be_success
      end
    end
  end

  describe 'POST /users registrations#create' do
    let(:endpoint) { '/users' }
    it 'creates a new User' do
      post endpoint, format: :json, user: { email: Faker::Internet.email,
                                            password: 'password',
                                            first_name: 'Foo',
                                            last_name: 'Bar',
                                            username: "user_#{Faker::Lorem.characters(10)}",
                                            bio: 'Foo to the Stars',
                                            industry: 'diner',
                                            photo: Rack::Test::UploadedFile.new(
                                              File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
                                          }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil
      new_user = User.find json_data['id']

      expect_json_keys(json_data, new_user, %w(id username first_name last_name sign_in_count bio))
      expect(json_data['auth_token']).to eq(new_user.authentication_token)
      expect(json_data['photos']).to_not be_nil
      expect_nil_json_keys(json_data, %w(password encrypted_password))
    end

    it 'creates a user_event' do
      expect {
        post endpoint, user: { email: Faker::Internet.email, password: 'password',
                        first_name: 'Foo', last_name: 'Bar', username: "user_#{Faker::Lorem.characters(10)}",
                        bio: 'Foo to the Stars'
                       },
                       __utmz: 'source=taco',
                       client: {
                        device: 'rspec',
                        version: '1.2.3'
                       },
                       format: :json
      }.to change(UserEvent, :count).by(1)

      user_event = UserEvent.last
      expect(user_event.name).to eq('created_account')
      expect(user_event.user_id).to_not be_nil
      expect(user_event.__utmz).to eq('source=taco')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end

    context 'authentication is passed' do
      it 'returns an error if an invalid authentication is passed' do
        post endpoint, format: :json, user: {
                                        email: Faker::Internet.email,
                                        password: 'password',
                                        first_name: 'Foo',
                                        last_name: 'Bar',
                                        username: "user_#{Faker::Lorem.characters(10)}",
                                        bio: 'Foo to the Stars',
                                        industry: 'diner',
                                        photo: Rack::Test::UploadedFile.new(
                                          File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                                      },
                                      authentication: {
                                        provider: 'myspace'
                                      }

          expect(response).to_not be_success
      end

      context 'Facebook' do
        it 'creates a new Facebook authentication for the new User' do
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

          post endpoint, format: :json, user: {
                                          email: Faker::Internet.email,
                                          password: 'password',
                                          first_name: 'Foo',
                                          last_name: 'Bar',
                                          username: "user_#{Faker::Lorem.characters(10)}",
                                          bio: 'Foo to the Stars',
                                          industry: 'diner',
                                          photo: Rack::Test::UploadedFile.new(
                                            File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                                        },
                                        authentication: {
                                          provider: 'facebook',
                                          token: dummy_token
                                        }

          expect(response).to be_success

          new_user = User.find json_data['id']
          new_facebook_user = FacebookAuthenticatedUserDecorator.new(new_user)
          expect(new_facebook_user.facebook_authentications.count).to eq(1)
          expect(new_facebook_user.facebook_uid).to eq(dummy_fb_uid)
        end
      end

      context 'Twitter' do
        it 'creates a new Twitter authentication for the new User' do
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

          post endpoint, format: :json, user: {
                                          email: Faker::Internet.email,
                                          password: 'password',
                                          first_name: 'Foo',
                                          last_name: 'Bar',
                                          username: "user_#{Faker::Lorem.characters(10)}",
                                          bio: 'Foo to the Stars',
                                          industry: 'diner',
                                          photo: Rack::Test::UploadedFile.new(
                                            File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                                        },
                                        authentication: {
                                          provider: 'twitter',
                                          token: dummy_token,
                                          secret: dummy_secret
                                        }

          expect(response).to be_success

          new_user = User.find json_data['id']
          new_twitter_user = TwitterAuthenticatedUserDecorator.new(new_user)
          expect(new_twitter_user.twitter_authentications.count).to eq(1)
          expect(new_twitter_user.twitter_username).to eq(dummy_screen_name)
        end
      end
    end
  end

  describe 'POST /users/sign_in sessions#create' do
    let(:endpoint) { '/users/sign_in' }
    let(:user) { FactoryGirl.create(:user) }

    context 'email/username and password' do
      it 'signs in the User' do
        post endpoint, format: :json, user: { email: user.email, password: 'password' }

        expect(response).to be_success

        expect_json_keys(json_data, user, %w(id username first_name last_name bio))
        expect(json_data['auth_token']).to eq(user.authentication_token)
        expect(json_data['photos']).to be_nil
        expect(json_data['sign_in_count']).to eq(1)
        expect_nil_json_keys(json_data, %w(password encrypted_password))
      end

      it 'accepts a username instead of an email' do
        post endpoint, format: :json, user: { username: user.username, password: 'password' }
        expect(response).to be_success
      end

      it 'accepts \'login\' as a generic parameter for email or username' do
        post endpoint, format: :json, user: { login: user.username, password: 'password' }
        expect(response).to be_success
      end

      it 'returns \'login or password\' error if invalid credentials' do
        post endpoint, format: :json, user: { email: 'butt', password: 'sack' }
        expect(response).to_not be_success
        expect(json_errors['base'].first).to eq('login or password is invalid')
      end
    end

    context 'facebook authentication' do
      let(:facebook_authentication) { FactoryGirl.create(:facebook_authentication, user: user) }
      it 'signs in the User' do
        stub_facebook_client
        post endpoint,  format: :json,
                        authentication: {
                          provider: facebook_authentication.provider,
                          token: facebook_authentication.token
                        }

        expect(response).to be_success

        expect_json_keys(json_data, user, %w(id username first_name last_name bio))
        expect(json_data['auth_token']).to eq(user.authentication_token)
        expect(json_data['photos']).to be_nil
        expect(json_data['sign_in_count']).to eq(1)
        expect_nil_json_keys(json_data, %w(password encrypted_password))
      end
    end

    context 'twitter authentication' do
      let(:twitter_authentication) { FactoryGirl.create(:twitter_authentication, user: user) }
      it 'signs in the User' do
        stub_twitter_client
        post endpoint,  format: :json,
                        authentication: {
                          provider: twitter_authentication.provider,
                          token: twitter_authentication.token,
                          secret: twitter_authentication.secret
                        }

        expect(response).to be_success

        expect_json_keys(json_data, user, %w(id username first_name last_name bio))
        expect(json_data['auth_token']).to eq(user.authentication_token)
        expect(json_data['photos']).to be_nil
        expect(json_data['sign_in_count']).to eq(1)
        expect_nil_json_keys(json_data, %w(password encrypted_password))
      end
    end
  end

  describe 'GET /users/{:user_id|user_username} users#show' do
    let(:endpoint) { "/users/#{user_with_morsels.id}" }
    let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
    let(:number_of_likes) { rand(2..6) }

    before { number_of_likes.times { Like.create(likeable: FactoryGirl.create(:item_with_creator), liker: user_with_morsels) }}

    it 'returns the User' do
      get endpoint, api_key: api_key_for_user(user_with_morsels), format: :json

      expect(response).to be_success

      expect_json_keys(json_data, user_with_morsels, %w(id username first_name last_name bio industry))
      expect_nil_json_keys(json_data, %w(password encrypted_password staff draft_count sign_in_count photo_processing auth_token email))

      expect(json_data['photos']).to be_nil
      expect(json_data['facebook_uid']).to eq(FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid)
      expect(json_data['twitter_username']).to eq(TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username)

      expect(json_data['liked_items_count']).to eq(number_of_likes)
      expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.count)
    end

    it 'should be public' do
      get endpoint, format: :json

      expect(response).to be_success

      expect_json_keys(json_data, user_with_morsels, %w(id username first_name last_name bio industry facebook_uid twitter_username))
      expect_nil_json_keys(json_data, %w(password encrypted_password staff draft_count sign_in_count photo_processing auth_token email))

      expect(json_data['liked_items_count']).to eq(number_of_likes)
      expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.count)
    end

    context 'User has Morsel drafts' do
      before do
        user_with_morsels.morsels << FactoryGirl.create(:draft_morsel_with_items)
      end

      it '`morsel_count` should NOT include draft Morsels' do
        get endpoint, format: :json

        expect(response).to be_success
        expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.published.count)
      end
    end

    context 'username passed instead of id' do
      it 'returns the User' do
        get "/users/#{user_with_morsels.username}", api_key: api_key_for_user(user_with_morsels), format: :json

        expect(response).to be_success

        expect_json_keys(json_data, user_with_morsels, %w(id username first_name last_name bio industry))
        expect_nil_json_keys(json_data, %w(password encrypted_password staff draft_count sign_in_count photo_processing auth_token email))

        expect(json_data['photos']).to be_nil
        expect(json_data['facebook_uid']).to eq(FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid)
        expect(json_data['twitter_username']).to eq(TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username)

        expect(json_data['liked_items_count']).to eq(number_of_likes)
        expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.count)
      end
    end

    context 'has a photo' do
      before do
        user_with_morsels.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
        user_with_morsels.save
      end

      it 'returns the User with the appropriate image sizes' do
        get endpoint, api_key: api_key_for_user(user_with_morsels), format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_144x144']).to_not be_nil
        expect(photos['_72x72']).to_not be_nil
        expect(photos['_80x80']).to_not be_nil
        expect(photos['_40x40']).to_not be_nil
      end
    end

    context 'current_user is following User' do
      let(:follower) { FactoryGirl.create(:user) }
      before do
        Follow.create(followable_id: user_with_morsels.id, followable_type: 'User', follower_id: follower.id)
      end

      it 'returns following=true' do
        get endpoint, api_key: api_key_for_user(follower), format: :json

        expect(response).to be_success
        expect(json_data['following']).to be_true
        expect(json_data['followed_users_count']).to eq(0)
        expect(json_data['follower_count']).to eq(1)
      end

      context 'User is following another User' do
        before do
          Follow.create(followable_id: FactoryGirl.create(:user).id, followable_type: 'User', follower_id: user_with_morsels.id)
        end

        it 'returns the correct following_count' do
          get endpoint, api_key: api_key_for_user(follower), format: :json
          expect(json_data['followed_users_count']).to eq(1)
          expect(json_data['follower_count']).to eq(1)
        end
      end
    end
  end

  describe 'GET /users/{:user_id}/likeables' do
    context 'type=Item' do
      let(:endpoint) { "/users/#{turd_ferg.id}/likeables?type=Item" }
      let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
      let(:liked_items_count) { rand(2..6) }

      before { liked_items_count.times { Like.create(likeable: FactoryGirl.create(:item_with_creator, morsel: FactoryGirl.create(:morsel_with_creator)), liker: turd_ferg) }}

      it 'returns the Items that the User has liked' do
        get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(liked_items_count)
        expect(json_data.first['liked_at']).to eq(Like.last.created_at.as_json)
      end
    end
  end

  describe 'GET /users/{:user_id}/followables' do
    context 'type=User' do
      let(:endpoint) { "/users/#{turd_ferg.id}/followables?type=User" }
      let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
      let(:followed_users_count) { rand(2..6) }

      before do
        followed_users_count.times { Follow.create(followable: FactoryGirl.create(:user), follower: turd_ferg) }
      end

      it 'returns the Users that the User has followed' do
        get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(followed_users_count)
        expect(json_data.first['followed_at']).to eq(Follow.last.created_at.as_json)
      end

      context 'unfollowed last User' do
        before do
          Follow.last.destroy
        end
        it 'returns one less followed user' do
          get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

          expect(response).to be_success

          expect(json_data.count).to eq(followed_users_count - 1)
        end
      end
    end
  end

  describe 'GET /users/{:user_id}/followers' do
    let(:endpoint) { "/users/#{turd_ferg.id}/followers" }
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }
    let(:followers_count) { rand(2..6) }

    before { followers_count.times { Follow.create(followable: turd_ferg, follower: FactoryGirl.create(:user)) }}

    it 'returns the Users that are following the User' do
      get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(followers_count)
      expect(json_data.first['followed_at']).to eq(Follow.last.created_at.as_json)
    end

    context 'last User unfollowed User' do
      before do
        Follow.last.destroy
      end
      it 'returns one less follower' do
        get endpoint, api_key: api_key_for_user(turd_ferg), format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(followers_count - 1)
      end
    end
  end

  describe 'PUT /users/{:user_id} users#update' do
    let(:endpoint) { "/users/#{turd_ferg.id}" }
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put endpoint, api_key: api_key_for_user(turd_ferg), format: :json, user: { first_name: new_first_name }

      expect(response).to be_success

      expect(json_data['first_name']).to eq(new_first_name)
      expect(json_data['email']).to eq(turd_ferg.email)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /users/{:user_id|user_username}/morsels' do
    let(:endpoint) { "/users/#{user_with_morsels.id}/morsels" }
    let(:morsels_count) { 3 }
    let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels, morsels_count: morsels_count) }

    it_behaves_like 'TimelinePaginateable' do
      let(:user) { FactoryGirl.create(:user_with_morsels) }
      let(:paginateable_object_class) { Morsel }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:morsel_with_creator, creator: user_with_morsels) }
      end
    end

    it 'returns all of the User\'s Morsels' do
      get endpoint, api_key: api_key_for_user(user_with_morsels), format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(user_with_morsels.morsels.count)
    end

    context 'has drafts' do
      let(:draft_morsels_count) { rand(3..6) }
      before do
        draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: user_with_morsels) }
      end

      it 'should NOT include drafts' do
        get endpoint, api_key: api_key_for_user(user_with_morsels),
                                                  format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(morsels_count)
      end
    end

    context 'username passed instead of id' do
      it 'returns all of the User\'s Morsels' do
        get "/users/#{user_with_morsels.username}/morsels", api_key: api_key_for_user(user_with_morsels), format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(user_with_morsels.morsels.count)
      end
    end
  end

  describe 'GET /users/authentications' do
    let(:endpoint) { '/users/authentications' }
    let(:user) { FactoryGirl.create(:user) }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Authentication }
      before do
        paginateable_object_class.delete_all
        15.times { FactoryGirl.create(:facebook_authentication, user: user) }
        15.times { FactoryGirl.create(:twitter_authentication, user: user) }
      end
    end

    it 'returns the current_user\'s Authentications' do
      get endpoint, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
    end
  end

  describe 'POST /users/authentications' do
    let(:endpoint) { '/users/authentications' }
    let(:chef) { FactoryGirl.create(:chef) }

    context 'Twitter' do
      it 'creates a new Twitter authentication' do
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

        post endpoint, api_key: api_key_for_user(chef),
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

        twitter_chef = TwitterAuthenticatedUserDecorator.new(chef)
        expect(twitter_chef.twitter_authentications.count).to eq(1)
        expect(twitter_chef.twitter_username).to eq(dummy_screen_name)
      end
    end

    context 'Facebook' do
      it 'creates a new Facebook authentication' do
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

        post endpoint, api_key: api_key_for_user(chef),
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

        facebook_chef = FacebookAuthenticatedUserDecorator.new(chef)
        expect(facebook_chef.facebook_authentications.count).to eq(1)
        expect(facebook_chef.facebook_uid).to eq(dummy_fb_uid)
      end
    end
  end

  describe 'GET /users/unsubscribe users#unsubscribe' do
    let(:endpoint) { '/users/unsubscribe' }
    let(:user) { FactoryGirl.create(:user) }

    it 'unsubscribes the user' do
      expect(user.unsubscribed).to be_false
      post endpoint, email: user.email
      expect(response).to be_success
      user.reload
      expect(user.unsubscribed).to be_true
    end
  end

  describe 'GET /users/activities' do
    let(:endpoint) { '/users/activities' }
    let(:user) { FactoryGirl.create(:user) }
    let(:items_count) { 3 }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    before do
      some_morsel.items.each do |item|
        Sidekiq::Testing.inline! { item.likers << user }
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Activity }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_like_activity, creator_id: user.id) }
      end
    end

    it 'returns the User\'s recent activities' do
      get endpoint, api_key: api_key_for_user(user), format: :json
      expect(response).to be_success
      expect(json_data.count).to eq(items_count)
      first_activity = json_data.first
      expect(first_activity['action_type']).to eq('Like')
      expect(first_activity['subject_type']).to eq('Item')

      # Since the activities call returns the newest first, compare against the last Item in some_morsel
      expect_json_keys(first_activity['subject'], some_morsel.items.last, %w(id description nonce))
    end

    context 'subject is deleted' do
      before do
        Like.last.destroy
      end

      it 'removes the Activity' do
        get endpoint, api_key: api_key_for_user(user),
                 format: :json
        expect(response).to be_success
        expect(json_data.count).to eq(items_count - 1)
      end
    end
  end

  describe 'GET /users/notifications' do
    let(:endpoint) { '/users/notifications' }
    let(:user) { FactoryGirl.create(:user) }
    let(:last_user) { FactoryGirl.create(:user) }
    let(:notifications_count) { 3 }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_creator, creator: user) }

    context 'an Item is liked' do
      before do
        notifications_count.times { FactoryGirl.create(:item_with_creator, creator: user, morsel:some_morsel) }
        user.items.each do |item|
          Sidekiq::Testing.inline! { item.likers << FactoryGirl.create(:user) }
        end
        Sidekiq::Testing.inline! { user.items.last.likers << last_user }
      end

      it 'returns the User\'s recent notifications' do
        get endpoint, api_key: api_key_for_user(user), format: :json
        expect(response).to be_success
        expect(json_data.count).to eq(notifications_count + 1)
        first_notification = json_data.first
        first_item = some_morsel.items.first

        expect(first_notification['message']).to eq("#{last_user.full_name} (#{last_user.username}) liked #{first_item.morsel_title_with_description}".truncate(100, separator: ' ', omission: '... '))
        expect(first_notification['payload_type']).to eq('Activity')
        expect(first_notification['payload']['action_type']).to eq('Like')
        expect(first_notification['payload']['subject_type']).to eq('Item')

        # Since the notifications call returns the newest first, compare against the last Item in some_morsel
        expect_json_keys(first_notification['payload']['subject'], first_item, %w(id description nonce))
      end

      context 'Item is unliked' do
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
