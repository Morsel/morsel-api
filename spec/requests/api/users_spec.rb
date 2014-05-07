require 'spec_helper'

describe 'Users API' do
  it_behaves_like 'TaggableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:taggable_route) { '/users' }
    let(:taggable) { current_user }
    let(:keyword) { FactoryGirl.create(:keyword) }
    let(:tag) { FactoryGirl.create(:user_tag, tagger: current_user) }
  end

  describe 'GET /users/me users#me' do
    let(:endpoint) { '/users/me' }
    let(:current_user) { FactoryGirl.create(:user) }

    it 'returns the authenticated User' do
      get_endpoint

      expect_success
      expect_json_keys(json_data, current_user, %w(id username first_name last_name sign_in_count bio staff email))
    end

    context 'has a Morsel draft' do
      let(:current_user) { FactoryGirl.create(:user_with_morsels) }
      before do
        current_user.morsels.first.update(draft: true)
      end

      it 'returns 1 for draft_count' do
        get_endpoint

        expect_success
        expect(json_data['draft_count']).to eq(1)
      end
    end

    context 'invalid api_key' do
      let(:current_user) { nil }
      it 'returns an unauthorized error' do
        get_endpoint api_key: '1:234567890'

        expect_failure
      end
    end
  end

  describe 'GET /users/validate_email users#validate_email' do
    let(:endpoint) { '/users/validate_email' }
    let(:user) { FactoryGirl.create(:user) }

    it 'returns true if the email does NOT exist' do
      get_endpoint email: 'marty@rock.lobster'

      expect_success
      expect(json_data).to eq(true)
    end

    it 'returns an error if the email is nil' do
      get_endpoint

      expect_failure
      expect(json_errors['email']).to include('is required')
    end

    it 'returns an error if the email is invalid' do
      get_endpoint email: 'a_bad_email_address'

      expect_failure
      expect(json_errors['email']).to include('is invalid')
    end

    it 'returns an error if the email already exists' do
      get_endpoint email: user.email

      expect_failure
      expect(json_errors['email']).to include('has already been taken')
    end

    it 'ignores case' do
      get_endpoint email: user.email.swapcase

      expect_failure
      expect(json_errors['email']).to include('has already been taken')
    end
  end

  describe 'GET /users/validateusername users#validateusername' do
    let(:endpoint) { '/users/validateusername' }
    let(:user) { FactoryGirl.create(:user) }

    it 'returns true if the username does NOT exist' do
      get_endpoint username: 'not_a_username'

      expect_success
      expect(json_data).to eq(true)
    end

    it 'returns an error if the username is nil' do
      get_endpoint

      expect_failure
      expect(json_errors['username']).to include('is required')
    end

    it 'returns an error if the username is too long' do
      get_endpoint username: 'longlonglonglong'

      expect_failure
      expect(json_errors['username']).to include('must be less than 16 characters')
    end

    it 'returns an error for spaces' do
      get_endpoint username: 'Bob Dole'

      expect_failure
      expect(json_errors['username']).to include('cannot contain spaces')
    end

    it 'returns an error if the username already exists' do
      get_endpoint username: user.username

      expect_failure
      expect(json_errors['username']).to include('has already been taken')
    end

    it 'ignores case' do
      get_endpoint username: user.username.swapcase

      expect_failure
      expect(json_errors['username']).to include('has already been taken')
    end

    context 'username is a reserved path' do
      let(:sample_reserved_path) { ReservedPaths.non_username_paths.sample }
      it 'returns true to say the username already exists' do
        get_endpoint username: sample_reserved_path

        expect_failure
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
      post_endpoint user: {
                      email: fake_email,
                      username: fake_username
                    }

      expect_success
      expect(json_data['user_id']).to_not be_nil

      user = User.find(json_data['user_id'])
      expect(user).to_not be_nil
      expect(user.email).to eq(fake_email)
      expect(user.username).to eq(fake_username)
      expect(user.active).to eq(false)
      expect(user.current_sign_in_ip).to_not be_nil
    end

    it 'sends an email' do
      expect {
        Sidekiq::Testing.inline! {
          post_endpoint user: {
                          email: fake_email,
                          username: fake_username
                        }
        }
      }.to change(MandrillMailer.deliveries, :count).by(1)

      expect_success
    end

    it 'creates a user_event' do
      expect {
        post_endpoint user: {
                        email: fake_email,
                        username: fake_username
                      },
                      __utmz: 'source=taco',
                      client: {
                        device: 'rspec',
                        version: '1.2.3'
                      }
      }.to change(UserEvent, :count).by(1)

      expect_success

      user_event = UserEvent.last
      expect(user_event.name).to eq('reserved_username')
      expect(user_event.user_id).to_not be_nil
      expect(user_event.__utmz).to eq('source=taco')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end

    context 'email already registered' do
      it 'returns an error' do
        post_endpoint user: {
                        email: user.email,
                        username: fake_username
                      }

        expect_failure
        expect(json_errors['email'].first).to eq('has already been taken')
      end
    end

    context 'username already registered' do
      it 'returns an error' do
        post_endpoint user: {
                        email: fake_email,
                        username: user.username
                      }

        expect_failure
        expect(json_errors['username'].first).to eq('has already been taken')
      end
    end
  end

  describe 'PUT /users/:user_id/updateindustry users#updateindustry' do
    let(:endpoint) { "/users/#{user.id}/updateindustry" }
    let(:user) { FactoryGirl.create(:user) }

    it 'sets the industry for the specified User' do
      put_endpoint  user: {
                      industry: 'media'
                    }

      expect_success
      expect(User.find(user.id).industry).to eq('media')
    end

    context 'invalid industry passed' do
      it 'throws an error' do
        put_endpoint  user: {
                        industry: 'butt'
                      }

        expect_failure
      end
    end
  end

  describe 'GET /users/check_authentication authentications#check' do
    let(:endpoint) { '/users/check_authentication' }

    it 'returns false' do
      get_endpoint  authentication: {
                      provider: 'facebook',
                      uid: 1234
                    }

      expect_success
      expect(json_data).to eq(false)
    end

    context 'Authentication exists' do
      let(:facebook_authentication) { FactoryGirl.create(:facebook_authentication) }

      it 'returns true' do
        get_endpoint  authentication: {
                        provider: facebook_authentication.provider,
                        uid: facebook_authentication.uid
                      }

        expect_success
        expect(json_data).to eq(false)
      end
    end
  end

  describe 'POST /users registrations#create' do
    let(:endpoint) { '/users' }
    it 'creates a new User' do
      post_endpoint user: {
                      email: Faker::Internet.email,
                      password: 'password',
                      first_name: 'Foo',
                      last_name: 'Bar',
                      username: "user_#{Faker::Lorem.characters(10)}",
                      bio: 'Foo to the Stars',
                      industry: 'diner',
                      photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
                    }

      expect_success
      expect(json_data['id']).to_not be_nil

      new_user = User.find json_data['id']
      expect_json_keys(json_data, new_user, %w(id username first_name last_name sign_in_count bio))
      expect(json_data['auth_token']).to eq(new_user.authentication_token)
      expect(json_data['photos']).to_not be_nil
      expect_nil_json_keys(json_data, %w(password encrypted_password))
    end

    it 'creates a user_event' do
      expect {
        post_endpoint user: {
                        email: Faker::Internet.email, password: 'password',
                        first_name: 'Foo', last_name: 'Bar', username: "user_#{Faker::Lorem.characters(10)}",
                        bio: 'Foo to the Stars'
                      },
                      __utmz: 'source=taco',
                      client: {
                        device: 'rspec',
                        version: '1.2.3'
                      }
      }.to change(UserEvent, :count).by(1)

      expect_success

      user_event = UserEvent.last
      expect(user_event.name).to eq('created_account')
      expect(user_event.user_id).to_not be_nil
      expect(user_event.__utmz).to eq('source=taco')
      expect(user_event.client_device).to eq('rspec')
      expect(user_event.client_version).to eq('1.2.3')
    end

    context 'authentication is passed' do
      it 'returns an error if an invalid authentication is passed' do
        post_endpoint user: {
                        email: Faker::Internet.email,
                        first_name: 'Foo',
                        last_name: 'Bar',
                        username: "user_#{Faker::Lorem.characters(10)}",
                        bio: 'Foo to the Stars',
                        industry: 'diner',
                        photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
                      },
                      authentication: {
                        provider: 'myspace'
                      }

          expect_failure
      end

      context 'Facebook' do
        it 'creates a new Facebook authentication for the new User' do
          stub_facebook_client
          post_endpoint user: {
                          email: Faker::Internet.email,
                          first_name: 'Foo',
                          last_name: 'Bar',
                          username: "user_#{Faker::Lorem.characters(10)}",
                          bio: 'Foo to the Stars',
                          industry: 'diner',
                          photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                        },
                        authentication: {
                          provider: 'facebook',
                          token: 'dummy_token'
                        }

          expect_success

          new_user = User.find json_data['id']
          new_facebook_user = FacebookAuthenticatedUserDecorator.new(new_user)
          expect(new_facebook_user.facebook_authentications.count).to eq(1)
          expect(new_facebook_user.facebook_uid).to eq('facebook_user_id')
        end

        context 'authentication already exists' do
          let(:authentication) { FactoryGirl.create(:facebook_authentication) }

          it 'returns an error' do
            authentication.update uid: 'facebook_user_id'
            stub_facebook_client
            post_endpoint user: {
                            email: Faker::Internet.email,
                            first_name: 'Foo',
                            last_name: 'Bar',
                            username: "user_#{Faker::Lorem.characters(10)}",
                            bio: 'Foo to the Stars',
                            industry: 'diner',
                            photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                          },
                          authentication: {
                            provider: authentication.provider,
                            token: authentication.token
                          }

            expect_failure
            expect(json_errors['authentication']).to include('already exists')
          end
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

          post_endpoint user: {
                          email: Faker::Internet.email,
                          first_name: 'Foo',
                          last_name: 'Bar',
                          username: "user_#{Faker::Lorem.characters(10)}",
                          bio: 'Foo to the Stars',
                          industry: 'diner',
                          photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                        },
                        authentication: {
                          provider: 'twitter',
                          token: dummy_token,
                          secret: dummy_secret
                        }

          expect_success

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
        post_endpoint user: {
                        email: user.email,
                        password: 'password'
                      }

        expect_success

        expect_json_keys(json_data, user, %w(id username first_name last_name bio))
        expect(json_data['auth_token']).to eq(user.authentication_token)
        expect(json_data['photos']).to be_nil
        expect(json_data['sign_in_count']).to eq(1)
        expect_nil_json_keys(json_data, %w(password encrypted_password))
      end

      it 'accepts a username instead of an email' do
        post_endpoint user: {
                        username: user.username,
                        password: 'password'
                      }
        expect_success
      end

      it 'accepts \'login\' as a generic parameter for email or username' do
        post_endpoint user: {
                        login: user.username,
                        password: 'password'
                      }
        expect_success
      end

      it 'returns \'login or password\' error if invalid credentials' do
        post_endpoint user: {
                        email: 'butt',
                        password: 'sack'
                      }
        expect_failure
        expect(json_errors['base'].first).to eq('login or password is invalid')
      end
    end

    context 'facebook authentication' do
      let(:facebook_authentication) { FactoryGirl.create(:facebook_authentication, user: user) }
      it 'signs in the User' do
        stub_facebook_client
        post_endpoint authentication: {
                        provider: facebook_authentication.provider,
                        token: facebook_authentication.token
                      }

        expect_success
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
        post_endpoint authentication: {
                        provider: twitter_authentication.provider,
                        token: twitter_authentication.token,
                        secret: twitter_authentication.secret
                      }

        expect_success
        expect_json_keys(json_data, user, %w(id username first_name last_name bio))
        expect(json_data['auth_token']).to eq(user.authentication_token)
        expect(json_data['photos']).to be_nil
        expect(json_data['sign_in_count']).to eq(1)
        expect_nil_json_keys(json_data, %w(password encrypted_password))
      end
    end
  end

  describe 'POST /users/forgot_password users#forgot_password' do
    let(:endpoint) { '/users/forgot_password' }
    let(:user) { FactoryGirl.create(:user) }

    it 'sends an email' do
      expect{
        Sidekiq::Testing.inline! { post_endpoint email: user.email }
      }.to change(MandrillMailer.deliveries, :count).by(1)

      expect_success
    end

    context 'email not found' do
      it 'returns an error' do
        post endpoint,  email: 'not_an_email',
                        format: :json
        expect_failure
        expect(json_errors['base']).to include('Record not found')
      end
    end
  end

  describe 'POST /users/reset_password users#reset_password' do
    let(:endpoint) { '/users/reset_password' }
    let(:user) { FactoryGirl.create(:user) }
    let(:new_password) { Faker::Lorem.characters(15) }

    before { user.send_reset_password_instructions }

    it 'resets the User\'s password' do
      post_endpoint reset_password_token: user.reset_password_token,
                    password: new_password

      expect_success

      user.reload
      expect(user.valid_password?(new_password)).to be_true
    end

    context 'invalid token' do
      it 'returns an error' do
        post_endpoint reset_password_token: 'b4d_t0k3n',
                      password: new_password

        expect_failure
        expect(json_errors['base']).to include('Record not found')
      end
    end
  end

  describe 'GET /users/{:user_id|user_username} users#show' do
    let(:endpoint) { "/users/#{user_with_morsels.id}" }
    let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
    let(:number_of_likes) { rand(2..6) }

    before { number_of_likes.times { Like.create(likeable: FactoryGirl.create(:item_with_creator), liker: user_with_morsels) }}

    it 'returns the User' do
      get_endpoint

      expect_success
      expect_json_keys(json_data, user_with_morsels, %w(id username first_name last_name bio industry))
      expect_nil_json_keys(json_data, %w(password encrypted_password staff draft_count sign_in_count photo_processing auth_token email))

      expect(json_data['photos']).to be_nil
      expect(json_data['facebook_uid']).to eq(FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid)
      expect(json_data['twitter_username']).to eq(TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username)

      expect(json_data['liked_items_count']).to eq(number_of_likes)
      expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.count)
    end

    context 'User has Morsel drafts' do
      before do
        user_with_morsels.morsels << FactoryGirl.create(:draft_morsel_with_items)
      end

      it '`morsel_count` should NOT include draft Morsels' do
        get_endpoint

        expect_success
        expect(json_data['morsel_count']).to eq(user_with_morsels.morsels.published.count)
      end
    end

    context 'username passed instead of id' do
      let(:endpoint) { "/users/#{user_with_morsels.username}" }
      it 'returns the User' do
        get_endpoint

        expect_success
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
        get_endpoint

        expect_success

        photos = json_data['photos']
        expect(photos['_144x144']).to_not be_nil
        expect(photos['_72x72']).to_not be_nil
        expect(photos['_80x80']).to_not be_nil
        expect(photos['_40x40']).to_not be_nil
      end
    end

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }
      context('following another User(A)') do
        let(:endpoint) { "/users/#{followed_user.id}" }
        let(:followed_user) { FactoryGirl.create(:user) }
        before do
          Follow.create(followable: followed_user, follower: current_user)
        end

        it 'returns following=true' do
          get_endpoint

          expect_success
          expect(json_data['following']).to be_true
          expect(json_data['followed_users_count']).to eq(0)
          expect(json_data['follower_count']).to eq(1)
        end

        context 'User(A) is following another User(B)' do
          before do
            Follow.create(followable: FactoryGirl.create(:user), follower: followed_user)
          end

          it 'returns the correct following_count' do
            get_endpoint
            expect(json_data['followed_users_count']).to eq(1)
            expect(json_data['follower_count']).to eq(1)
          end
        end
      end
    end
  end

  describe 'GET /users/{:user_id}/likeables' do
    context 'type=Item' do
      let(:endpoint) { "/users/#{liker.id}/likeables?type=Item" }
      let(:liker) { FactoryGirl.create(:user) }
      let(:liked_items_count) { rand(2..6) }

      before { liked_items_count.times { FactoryGirl.create(:item_like, liker: liker, likeable: FactoryGirl.create(:item_with_creator_and_morsel)) }}

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
        expect(json_data.count).to eq(liked_items_count)
        expect(json_data.first['liked_at']).to eq(Like.last.created_at.as_json)
      end
    end
  end

  describe 'GET /users/{:user_id}/followables' do
    context 'type=User' do
      let(:endpoint) { "/users/#{follower.id}/followables?type=User" }
      let(:follower) { FactoryGirl.create(:user) }
      let(:followed_users_count) { rand(2..6) }

      before do
        followed_users_count.times { FactoryGirl.create(:user_follow, followable: FactoryGirl.create(:user), follower: follower) }
      end

      it_behaves_like 'TimelinePaginateable' do
        let(:paginateable_object_class) { User }
        before do
          paginateable_object_class.delete_all
          30.times { FactoryGirl.create(:user_follow, follower: follower) }
        end
      end

      it 'returns the Users that the User has followed' do
        get_endpoint

        expect_success
        expect(json_data.count).to eq(followed_users_count)
        expect(json_data.first['followed_at']).to eq(Follow.last.created_at.as_json)
      end

      context 'unfollowed last User' do
        before do
          Follow.last.destroy
        end
        it 'returns one less followed user' do
          get_endpoint

          expect_success
          expect(json_data.count).to eq(followed_users_count - 1)
        end
      end
    end
  end

  describe 'GET /users/{:user_id}/followers' do
    let(:endpoint) { "/users/#{followed_user.id}/followers" }
    let(:followed_user) { FactoryGirl.create(:user) }
    let(:followers_count) { rand(2..6) }

    before { followers_count.times { FactoryGirl.create(:user_follow, followable: followed_user) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user_follow, followable: followed_user) }
      end
    end

    it 'returns the Users that are following the User' do
      get_endpoint

      expect_success

      expect(json_data.count).to eq(followers_count)
      expect(json_data.first['followed_at']).to eq(Follow.last.created_at.as_json)
    end

    context 'last User unfollowed User' do
      before do
        Follow.last.destroy
      end
      it 'returns one less follower' do
        get_endpoint

        expect_success

        expect(json_data.count).to eq(followers_count - 1)
      end
    end
  end

  describe 'PUT /users/{:user_id} users#update' do
    let(:endpoint) { "/users/#{current_user.id}" }
    let(:current_user) { FactoryGirl.create(:user) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put_endpoint user: { first_name: new_first_name }

      expect_success

      expect(json_data['first_name']).to eq(new_first_name)
      expect(json_data['email']).to eq(current_user.email)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /users/{:user_id|user_username}/morsels' do
    let(:endpoint) { "/users/#{user_with_morsels.id}/morsels" }
    let(:morsels_count) { 3 }
    let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels, morsels_count: morsels_count) }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Morsel }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:morsel_with_creator, creator: user_with_morsels) }
      end
    end

    it 'returns all of the User\'s Morsels' do
      get_endpoint

      expect_success

      expect(json_data.count).to eq(user_with_morsels.morsels.count)
    end

    context 'has drafts' do
      let(:draft_morsels_count) { rand(3..6) }
      before do
        draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: user_with_morsels) }
      end

      it 'should NOT include drafts' do
        get_endpoint

        expect_success

        expect(json_data.count).to eq(morsels_count)
      end
    end

    context 'username passed instead of id' do
      let(:endpoint) { "/users/#{user_with_morsels.username}/morsels" }
      it 'returns all of the User\'s Morsels' do
        get_endpoint

        expect_success

        expect(json_data.count).to eq(user_with_morsels.morsels.count)
      end
    end
  end

  describe 'GET /users/authentications authentications#index' do
    let(:endpoint) { '/users/authentications' }
    let(:current_user) { FactoryGirl.create(:user) }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Authentication }
      before do
        paginateable_object_class.delete_all
        15.times { FactoryGirl.create(:facebook_authentication, user: current_user) }
        15.times { FactoryGirl.create(:twitter_authentication, user: current_user) }
      end
    end

    it 'returns the current_user\'s Authentications' do
      get_endpoint

      expect_success
    end
  end

  describe 'POST /users/authentications authentications#create' do
    let(:endpoint) { '/users/authentications' }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:screen_name) { 'eatmorsel' }
    let(:token) { 'token' }
    let(:secret) { 'secret' }

    context 'Twitter' do
      it 'creates a new Twitter authentication' do
        stub_twitter_client
        post_endpoint provider: 'twitter',
                      token: token,
                      secret: secret

        expect_success

        expect(json_data['id']).to_not eq(123)
        expect(json_data['provider']).to eq('twitter')
        expect(json_data['secret']).to eq(secret)
        expect(json_data['token']).to eq(token)
        expect(json_data['user_id']).to eq(current_user.id)
        expect(json_data['name']).to eq(screen_name)

        twitter_authenticated_user = TwitterAuthenticatedUserDecorator.new(current_user)
        expect(twitter_authenticated_user.twitter_authentications.count).to eq(1)
        expect(twitter_authenticated_user.twitter_username).to eq(screen_name)
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

        post_endpoint provider: 'facebook',
                      token: dummy_token

        expect_success

        expect(json_data['uid']).to eq(dummy_fb_uid)
        expect(json_data['provider']).to eq('facebook')
        expect(json_data['secret']).to be_nil
        expect(json_data['token']).to eq(dummy_token)
        expect(json_data['user_id']).to eq(current_user.id)
        expect(json_data['name']).to eq(dummy_name)

        facebook_authenticated_user = FacebookAuthenticatedUserDecorator.new(current_user)
        expect(facebook_authenticated_user.facebook_authentications.count).to eq(1)
        expect(facebook_authenticated_user.facebook_uid).to eq(dummy_fb_uid)
      end
    end
  end

  describe 'DELETE /users/authentications/{:authentication_id} authentications#destroy' do
    let(:endpoint) { "/users/authentications/#{authentication.id}" }
    let(:current_user) { FactoryGirl.create(:chef_with_facebook_authentication) }
    let(:authentication) { current_user.authentications.first }

    it 'destroys the authentication for the current_user' do
      delete_endpoint

      expect_success
      expect(Authentication.find_by(id: authentication.id)).to be_nil
    end
  end

  describe 'GET /users/unsubscribe users#unsubscribe' do
    let(:endpoint) { '/users/unsubscribe' }
    let(:user) { FactoryGirl.create(:user) }

    it 'unsubscribes the user' do
      expect(user.unsubscribed).to be_false

      post_endpoint email: user.email

      expect_success
      user.reload
      expect(user.unsubscribed).to be_true
    end
  end

  describe 'GET /users/activities' do
    let(:endpoint) { '/users/activities' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:items_count) { 3 }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    before do
      some_morsel.items.each do |item|
        Sidekiq::Testing.inline! { item.likers << current_user }
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Activity }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_like_activity, creator_id: current_user.id) }
      end
    end

    it 'returns the User\'s recent activities' do
      get_endpoint

      expect_success
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
        get_endpoint

        expect_success
        expect(json_data.count).to eq(items_count - 1)
      end
    end
  end

  describe 'GET /users/notifications' do
    let(:endpoint) { '/users/notifications' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:last_user) { FactoryGirl.create(:user) }
    let(:notifications_count) { 3 }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_creator, creator: current_user) }

    context 'an Item is liked' do
      before do
        notifications_count.times { FactoryGirl.create(:item_with_creator, creator: current_user, morsel:some_morsel) }
        current_user.items.each do |item|
          Sidekiq::Testing.inline! { item.likers << FactoryGirl.create(:user) }
        end
        Sidekiq::Testing.inline! { current_user.items.last.likers << last_user }
      end

      it 'returns the User\'s recent notifications' do
        get_endpoint

        expect_success
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
          get_endpoint

          expect_success
          expect(json_data.count).to eq(notifications_count)
        end
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Notification }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:activity_notification, user: current_user) }
      end
    end
  end
end
