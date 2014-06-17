require 'spec_helper'

describe 'Users API' do
  it_behaves_like 'FollowableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:followable_route) { '/users' }
    let(:followable) { FactoryGirl.create(:user) }
  end

  it_behaves_like 'TaggableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:taggable_route) { '/users' }
    let(:taggable) { current_user }
    let(:keyword) { FactoryGirl.create(:cuisine) }
    let(:existing_tag) { FactoryGirl.create(:user_cuisine_tag, tagger: current_user) }
  end

  describe 'GET /users/search users#search' do
    let(:endpoint) { '/users/search' }
    let(:current_user) { FactoryGirl.create(:user) }

    context 'query' do
      before do
        FactoryGirl.create(:user, first_name: 'TURd')
        FactoryGirl.create(:user, last_name: 'tURD')
      end

      it 'returns Users matching both `first_name` and `last_name`' do
        get_endpoint  user: {
                              query: 'turd'
                            }

        expect_success
        expect_json_data_count 2
        expect(json_data.first['following']).to be_false
      end

      it 'returns inpartial matches' do
        get_endpoint  user: {
                              query: 'tur'
                            }

        expect_success
        expect_json_data_count 2
        expect(json_data.first['following']).to be_false
      end
    end

    context 'promoted' do
      let(:promoted_users_count) { rand(2..6) }
      before do
        promoted_users_count.times { FactoryGirl.create(:user, promoted: true) }
        rand(1..3).times { FactoryGirl.create(:user) }
      end

      it_behaves_like 'TimelinePaginateable' do
        let(:paginateable_object_class) { User }
        let(:additional_params) {{ user: { promoted: true }}}

        before do
          paginateable_object_class.delete_all
          30.times { FactoryGirl.create(:user, promoted: true) }
        end
      end

      it 'returns `promoted` Users' do
        get_endpoint  user: {
                        promoted: true
                      }

        expect_success
        expect_json_data_count promoted_users_count
      end
    end

    context 'first_name' do
      let(:users_first_named_turd_count) { rand(2..6) }
      before do
        users_first_named_turd_count.times { FactoryGirl.create(:user, first_name: 'Turd') }
        rand(1..3).times { FactoryGirl.create(:user) }
      end

      it 'returns Users matching `first_name`' do
        get_endpoint  user: {
                        first_name: 'Turd'
                      }

        expect_success
        expect_json_data_count users_first_named_turd_count
      end

      it 'is case insensitive' do
        get_endpoint  user: {
                        first_name: 'tURD'
                      }

        expect_success
        expect_json_data_count users_first_named_turd_count
      end
    end

    context 'last_name' do
      let(:users_last_named_ferguson_count) { rand(2..6) }
      before do
        users_last_named_ferguson_count.times { FactoryGirl.create(:user, last_name: 'Turd') }
        rand(1..3).times { FactoryGirl.create(:user) }
      end

      it 'returns Users matching `last_name`' do
        get_endpoint  user: {
                        last_name: 'Turd'
                      }

        expect_success
        expect_json_data_count users_last_named_ferguson_count
      end
    end

    context 'first_name and last_name' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        rand(1..3).times { FactoryGirl.create(:user) }
      end

      context '`current_user` is following `user`' do
        before do
          Follow.create(followable: user, follower: current_user)
        end

        it 'returns `following` true' do
          get_endpoint  user: {
                          first_name: user.first_name,
                          last_name: user.last_name
                        }

          expect_success
          expect(json_data.first['following']).to be_true
        end
      end

      it 'returns Users matching `first_name` and `last_name`' do
        get_endpoint  user: {
                        first_name: user.first_name,
                        last_name: user.last_name
                      }

        expect_success
        expect_json_data_count 1
      end
    end
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
        expect_json_data_eq('draft_count' => 1)
      end
    end

    context 'invalid api_key' do
      let(:current_user) { nil }
      it 'returns an unauthorized error' do
        get_endpoint api_key: '1:234567890'

        expect_failure
        expect_status 401
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
                      photo: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png'))),
                      promoted: true
                    }

      expect_success
      expect(json_data['id']).to_not be_nil

      new_user = User.find json_data['id']
      expect_json_data_eq({
        'id' => new_user.id,
        'username' => new_user.username,
        'first_name' => new_user.first_name,
        'last_name' => new_user.last_name,
        'sign_in_count' => new_user.sign_in_count,
        'bio' => new_user.bio,
        'auth_token' => new_user.authentication_token,
        'password' => nil,
        'encrypted_password' => nil
      })

      expect(new_user.promoted).to be_false

      expect(json_data['photos']).to_not be_nil
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
        context 'short-lived token is passed' do
          let(:short_lived_token) { 'short_lived_token' }

          it 'exchanges for a new token' do
            stub_facebook_client
            stub_facebook_oauth(short_lived_token)

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
                            uid: 'facebook_uid',
                            token: short_lived_token,
                            short_lived: true
                          }

            expect_success
            expect(Authentication.last.token).to eq('new_access_token')
          end
        end

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
                          uid: 'facebook_uid',
                          token: 'dummy_token'
                        }

          expect_success

          new_user = User.find json_data['id']
          new_facebook_user = FacebookAuthenticatedUserDecorator.new(new_user)
          expect(new_facebook_user.facebook_authentications.count).to eq(1)
          expect(new_facebook_user.facebook_uid).to eq('facebook_user_id')
          expect(new_facebook_user.uid).to eq('facebook_user_id')
          expect(new_facebook_user.provider).to eq('facebook')
        end
      end

      context 'Twitter' do
        it 'creates a new Twitter authentication for the new User' do
          stub_twitter_client
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
                          uid: 'twitter_uid',
                          token: 'dummy_token',
                          secret: 'dummy_secret'
                        }

          expect_success

          new_user = User.find json_data['id']
          new_twitter_user = TwitterAuthenticatedUserDecorator.new(new_user)
          expect(new_twitter_user.twitter_authentications.count).to eq(1)
          expect(new_twitter_user.twitter_username).to eq('eatmorsel')
          expect(new_twitter_user.uid).to eq('twitter_user_id')
          expect(new_twitter_user.provider).to eq('twitter')
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
                        password: user.password
                      }

        expect_success
        expect_json_data_eq({
          'id' => user.id,
          'username' => user.username,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'bio' => user.bio,
          'auth_token' => user.authentication_token,
          'sign_in_count' => 1,
          'password' => nil,
          'encrypted_password' => nil
        })

        expect(json_data['photos']).to be_nil
      end

      it 'accepts a username instead of an email' do
        post_endpoint user: {
                        username: user.username,
                        password: user.password
                      }
        expect_success
      end

      it 'accepts \'login\' as a generic parameter for email or username' do
        post_endpoint user: {
                        login: user.username,
                        password: user.password
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

      context 'inactive User' do
        before { user.update(active: false) }

        it 'returns an error' do
          post_endpoint user: {
                          email: user.email,
                          password: user.password
                        }

          expect_failure
          expect(json_errors['base'].first).to eq('login or password is invalid')
        end
      end
    end

    context 'authentication already exists' do
      let(:authentication) { FactoryGirl.create(:facebook_authentication) }

      it 'updates the authentication `token` and `secret`' do
        stub_facebook_client(id: authentication.uid)

        post_endpoint authentication: {
                        provider: authentication.provider,
                        uid: authentication.uid,
                        token: 'new_token'
                      }

        authentication.reload
        expect(authentication.token).to eq('new_token')
      end
    end

    context 'token for a different Facebook User passed' do
      let(:authentication) { FactoryGirl.create(:facebook_authentication) }
      let(:other_authentication) { FactoryGirl.create(:facebook_authentication) }
      it 'throws an error' do
        stub_facebook_client(id: other_authentication.uid)

        post_endpoint authentication: {
                        provider: authentication.provider,
                        uid: authentication.uid,
                        token: other_authentication.token
                      }
        expect_failure
        expect(json_errors['base'].first).to eq('login or password is invalid')
      end
    end

    context 'facebook authentication' do
      let(:facebook_authentication) { FactoryGirl.create(:facebook_authentication, user: user) }
      it 'signs in the User' do
        stub_facebook_client(id: facebook_authentication.uid)

        post_endpoint authentication: {
                        provider: facebook_authentication.provider,
                        uid: facebook_authentication.uid,
                        token: facebook_authentication.token
                      }

        expect_success
        expect_json_data_eq({
          'id' => user.id,
          'username' => user.username,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'bio' => user.bio,
          'auth_token' => user.authentication_token,
          'sign_in_count' => 1,
          'password' => nil,
          'encrypted_password' => nil
        })
        expect(json_data['photos']).to be_nil
      end

      context 'short-lived token is passed' do
        let(:short_lived_token) { 'short_lived_token' }

        it 'exchanges for a new token' do
          stub_facebook_client(id: facebook_authentication.uid)
          stub_facebook_oauth(short_lived_token)

          post_endpoint authentication: {
                          provider: facebook_authentication.provider,
                          uid: facebook_authentication.uid,
                          token: short_lived_token,
                          short_lived: true
                        }

          expect_success
          facebook_authentication.reload
          expect(facebook_authentication.token).to eq('new_access_token')
        end
      end
    end

    context 'twitter authentication' do
      let(:twitter_authentication) { FactoryGirl.create(:twitter_authentication, user: user) }
      it 'signs in the User' do
        stub_twitter_client(id: twitter_authentication.uid)
        post_endpoint authentication: {
                        provider: twitter_authentication.provider,
                        uid: twitter_authentication.uid,
                        token: twitter_authentication.token,
                        secret: twitter_authentication.secret
                      }

        expect_success
        expect_json_data_eq({
          'id' => user.id,
          'username' => user.username,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'bio' => user.bio,
          'auth_token' => user.authentication_token,
          'sign_in_count' => 1,
          'password' => nil,
          'encrypted_password' => nil
        })
        expect(json_data['photos']).to be_nil
      end
    end
  end

  describe 'POST /users/forgot_password users#forgot_password' do
    let(:endpoint) { '/users/forgot_password' }
    let(:user) { FactoryGirl.create(:user) }

    it 'sends an email' do
      expect{
        Sidekiq::Testing.inline! { post_endpoint email: user.email }
      }.to change(Devise::Mailer.deliveries, :count).by(1)

      expect_success
    end

    context 'email not found' do
      it 'still succeeds' do
        post_endpoint email: 'not_an_email'
        expect_success
      end
    end
  end

  describe 'POST /users/reset_password users#reset_password' do
    let(:endpoint) { '/users/reset_password' }
    let(:user) { FactoryGirl.create(:user) }
    let(:new_password) { Faker::Lorem.characters(15) }
    let(:raw_token) { user.send_reset_password_instructions }

    before { raw_token }

    it 'resets the User\'s password' do
      post_endpoint reset_password_token: raw_token,
                    password: new_password

      expect_success

      user.reload
      expect(user.valid_password?(new_password)).to be_true
    end

    it 'changes the User\'s authentication_token' do
      expect{
        post_endpoint reset_password_token: raw_token,
                      password: new_password
        user.reload
      }.to change(user, :authentication_token)
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

  describe 'GET /users/:id|:username users#show' do
    let(:endpoint) { "/users/#{user_with_morsels.id}" }
    let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
    let(:number_of_likes) { rand(2..6) }

    before { number_of_likes.times { Like.create(likeable: FactoryGirl.create(:item_with_creator), liker: user_with_morsels) }}

    it 'returns the User' do
      get_endpoint

      expect_success
      expect_json_data_eq({
        'id' => user_with_morsels.id,
        'username' => user_with_morsels.username,
        'first_name' => user_with_morsels.first_name,
        'last_name' => user_with_morsels.last_name,
        'bio' => user_with_morsels.bio,
        'industry' => user_with_morsels.industry,
        'email' => nil,
        'password' => nil,
        'encrypted_password' => nil,
        'photos' => nil,
        'facebook_uid' => FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid,
        'twitter_username' => TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username,
        'liked_item_count' => number_of_likes,
        'morsel_count' => user_with_morsels.morsels.count
      })
    end

    context 'User has Morsel drafts' do
      before do
        user_with_morsels.morsels << FactoryGirl.create(:draft_morsel_with_items)
      end

      it '`morsel_count` should NOT include draft Morsels' do
        get_endpoint

        expect_success
        expect_json_data_eq('morsel_count' => user_with_morsels.morsels.published.count)
      end
    end

    context 'username passed instead of id' do
      let(:endpoint) { "/users/#{user_with_morsels.username}" }
      it 'returns the User' do
        get_endpoint

        expect_success
        expect_json_data_eq({
          'id' => user_with_morsels.id,
          'username' => user_with_morsels.username,
          'first_name' => user_with_morsels.first_name,
          'last_name' => user_with_morsels.last_name,
          'bio' => user_with_morsels.bio,
          'industry' => user_with_morsels.industry,
          'email' => nil,
          'password' => nil,
          'encrypted_password' => nil,
          'photos' => nil,
          'facebook_uid' => FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid,
          'twitter_username' => TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username,
          'liked_item_count' => number_of_likes,
          'morsel_count' => user_with_morsels.morsels.count
        })
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
          expect_json_data_eq({
            'following' => true,
            'followed_user_count' => 0,
            'follower_count' => 1
          })
        end

        context 'User(A) is following another User(B)' do
          before do
            Follow.create(followable: FactoryGirl.create(:user), follower: followed_user)
          end

          it 'returns the correct following_count' do
            get_endpoint

            expect_success
            expect_json_data_eq({
              'followed_user_count' => 1,
              'follower_count' => 1
            })
          end
        end
      end
    end
  end

  describe 'GET /users/:id/likeables' do
    context 'type=Item' do
      let(:endpoint) { "/users/#{liker.id}/likeables?type=Item" }
      let(:liker) { FactoryGirl.create(:user) }
      let(:liked_item_count) { rand(2..6) }

      before { liked_item_count.times { FactoryGirl.create(:item_like, liker: liker, likeable: FactoryGirl.create(:item_with_creator_and_morsel)) }}

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
        expect_json_data_count liked_item_count
        expect_first_json_data_eq('liked_at' => Like.last.created_at.as_json)
      end
    end
  end

  describe 'GET /users/:id/followables' do
    context 'type=Keyword' do
      let(:endpoint) { "/users/#{follower.id}/followables?type=Keyword" }
      let(:follower) { FactoryGirl.create(:user) }
      let(:followed_keywords_count) { rand(2..6) }

      before do
        followed_keywords_count.times { FactoryGirl.create(:keyword_follow, followable: FactoryGirl.create(:cuisine), follower: follower) }
      end

      it_behaves_like 'TimelinePaginateable' do
        let(:paginateable_object_class) { Keyword }
        before do
          paginateable_object_class.delete_all
          30.times { FactoryGirl.create(:keyword_follow, follower: follower) }
        end
      end

      it 'returns the Keywords that the User has followed' do
        get_endpoint

        expect_success

        expect_json_data_count followed_keywords_count
        expect_first_json_data_eq('followed_at' => Follow.last.created_at.as_json)
      end

      context 'unfollowed last Keyword' do
        before do
          Follow.last.destroy
        end
        it 'returns one less followed user' do
          get_endpoint

          expect_success
          expect_json_data_count(followed_keywords_count - 1)
        end
      end
    end

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
        expect_json_data_count followed_users_count
        expect_first_json_data_eq('followed_at' => Follow.last.created_at.as_json)
      end

      context 'unfollowed last User' do
        before do
          Follow.last.destroy
        end
        it 'returns one less followed user' do
          get_endpoint

          expect_success
          expect_json_data_count(followed_users_count - 1)
        end
      end
    end
  end

  describe 'PUT /users/:id users#update' do
    let(:endpoint) { "/users/#{current_user.id}" }
    let(:current_user) { FactoryGirl.create(:user) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put_endpoint user: {
        first_name: new_first_name,
        settings: {
          auto_follow: true
        }
      }

      expect_success
      expect_json_data_eq({
        'first_name' => new_first_name,
        'email' => current_user.email,
        'settings' => {
          'auto_follow' => 'true'
        }
      })
      expect(json_data['auth_token']).to be_nil

      expect(User.first.first_name).to eq(new_first_name)
      expect(User.first.auto_follow?).to eq(true)
    end

    context 'email changed' do
      let(:new_email) { 'bobby@tables.com' }
      it 'fails if `current_password` is not specified' do
        put_endpoint user: { email: new_email }

        expect_failure
        expect(json_errors['current_password']).to include('is required to change email')
      end

      it 'updates if `current_password` is specified' do
        put_endpoint user: { email: new_email, current_password: current_user.password }

        expect_success
        expect_json_data_eq('email' => new_email)
        expect(json_data['auth_token']).to be_nil

        expect(User.first.email).to eq(new_email)
      end
    end

    context 'username changed' do
      let(:new_username) { 'bobby' }
      it 'fails if `current_password` is not specified' do
        put_endpoint user: { username: new_username }

        expect_failure
        expect(json_errors['current_password']).to include('is required to change username')
      end

      it 'updates if `current_password` is specified' do
        put_endpoint user: { username: new_username, current_password: current_user.password }

        expect_success
        expect_json_data_eq('username' => new_username)
        expect(json_data['auth_token']).to be_nil

        expect(User.first.username).to eq(new_username)
      end
    end

    context 'password changed' do
      let(:new_password) { 'awesome_password' }
      it 'fails if `current_password` is not specified' do
        put_endpoint user: { password: new_password }

        expect_failure
        expect(json_errors['current_password']).to include('is required to change password')
      end

      it 'updates if `current_password` is specified and regenerates `authentication_token`' do
        current_authentication_token = current_user.authentication_token

        expect{
          put_endpoint user: { password: new_password, current_password: current_user.password }
          current_user.reload
        }.to change(current_user, :authentication_token)

        expect_success
        expect(json_data['auth_token']).to_not eq(current_authentication_token)

        expect(User.first.valid_password?(new_password)).to be_true
      end
    end
  end

  describe 'GET /users/:id|:username/morsels' do
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

      expect_json_data_count user_with_morsels.morsels.count
    end

    context 'has drafts' do
      let(:draft_morsels_count) { rand(3..6) }
      before do
        draft_morsels_count.times { FactoryGirl.create(:draft_morsel_with_items, creator: user_with_morsels) }
      end

      it 'should NOT include drafts' do
        get_endpoint

        expect_success

        expect_json_data_count morsels_count
      end
    end

    context 'username passed instead of id' do
      let(:endpoint) { "/users/#{user_with_morsels.username}/morsels" }
      it 'returns all of the User\'s Morsels' do
        get_endpoint

        expect_success

        expect_json_data_count user_with_morsels.morsels.count
      end
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
      if current_user
        some_morsel.items.each do |item|
          Sidekiq::Testing.inline! { item.likers << current_user }
        end
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
      expect_json_data_count items_count

      last_item = some_morsel.items.last
      last_item_creator = last_item.creator
      last_item_morsel = last_item.morsel

      expect_first_json_data_eq({
        'action_type' => 'Like',
        'subject_type' => 'Item',
        'subject' => {
          'id' => last_item.id,
          'description' => last_item.description,
          'nonce' => last_item.nonce,
          'creator' => {
            'id' => last_item_creator.id,
            'username' => last_item_creator.username,
            'first_name' => last_item_creator.first_name,
            'last_name' => last_item_creator.last_name
          },
          'morsel' => {
            'id' => last_item_morsel.id,
            'title' => last_item_morsel.title,
            'slug' => last_item_morsel.slug
          }
        }
      })
    end

    context 'subject is deleted' do
      before do
        Like.last.destroy
      end

      it 'removes the Activity' do
        get_endpoint

        expect_success
        expect_json_data_count(items_count - 1)
      end
    end

    context 'invalid api_key' do
      let(:current_user) { nil }
      it 'returns an unauthorized error' do
        get_endpoint api_key: '1:234567890'

        expect_failure
        expect_status 401
      end
    end
  end

  describe 'GET /users/followables_activities' do
    let(:endpoint) { '/users/followables_activities' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:followed_users) { [FactoryGirl.create(:user), FactoryGirl.create(:user)] }
    let(:items_count) { 3 }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_items, items_count: items_count) }

    before do
      followed_users.each do |fu|
        current_user.followed_users << fu
      end

      some_morsel.items.each do |item|
        Sidekiq::Testing.inline! { item.likers << followed_users.sample }
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Activity }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:item_like_activity, creator_id: followed_users.sample.id) }
      end
    end

    it 'returns the User\'s Followed Users\' recent activities' do
      get_endpoint

      expect_success
      expect_json_data_count items_count

      last_item = some_morsel.items.last
      expect_first_json_data_eq({
        'action_type' => 'Like',
        'subject_type' => 'Item',
        'subject' => {
          'id' => last_item.id,
          'description' => last_item.description,
          'nonce' => last_item.nonce
        }
      })
    end

    context 'subject is deleted' do
      before do
        Like.last.destroy
      end

      it 'removes the Activity' do
        get_endpoint

        expect_success
        expect_json_data_count(items_count - 1)
      end
    end
  end

  describe 'GET /users/:id/places' do
    let(:endpoint) { "/users/#{user.id}/places" }
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:user) { FactoryGirl.create(:user) }
    let(:place_count) { rand(2..6) }

    before do
      place_count.times { FactoryGirl.create(:employment, user: user) }
    end

    it 'returns Places associated with the User' do
      get_endpoint

      expect_success
      expect_json_data_count place_count

      expect_first_json_data_eq title: Employment.last.title
    end
  end
end
