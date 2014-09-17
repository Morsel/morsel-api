require_relative '_spec_helper'

describe 'POST /users registrations#create' do
  let(:endpoint) { '/users' }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:presigned_photo_uploadable_object) {
      {
        user: {
          email: Faker::Internet.email,
          password: 'password',
          first_name: 'Foo',
          last_name: 'Bar',
          username: "user_#{Faker::Lorem.characters(10)}"
        }
      }
    }
    let(:endpoint_method) { :post }
  end

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
      'encrypted_password' => nil,
      'password_set' => true
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
          new_user = User.find json_data['id']
          expect(new_user.password_set).to be_false
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
        expect(new_facebook_user.password_set).to be_false
      end

      context 'Facebook friends already on Morsel' do
        let(:number_of_connections) { rand(2..6) }
        let(:stubbed_connections) do
          _stubbed_connections = []
          number_of_connections.times { _stubbed_connections << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
          _stubbed_connections
        end

        it 'finds and follows any Facebook friends on Morsel' do
          stubbed_connections.each do |c|
            FactoryGirl.create(:facebook_authentication, uid: c['id'], name: c['name'])
          end
          stub_facebook_client(connections: stubbed_connections)

          Sidekiq::Testing.inline! do
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
          end

          expect_success

          new_user = User.find json_data['id']
          expect(new_user.followed_user_count).to eq(number_of_connections)
        end
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
        expect(new_twitter_user.password_set).to be_false
      end

      context 'Twitter friends already on Morsel' do
        let(:number_of_connections) { rand(2..6) }
        let(:stubbed_connections) do
          _stubbed_connections = []
          number_of_connections.times { _stubbed_connections << Faker::Number.number(rand(5..10)) }
          _stubbed_connections
        end

        it 'finds and follows any Facebook friends on Morsel' do
          stubbed_connections.each do |c|
            FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
          end
          stub_twitter_client(connections: stubbed_connections)

          Sidekiq::Testing.inline! do
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
          end

          expect_success

          new_user = User.find json_data['id']
          expect(new_user.followed_user_count).to eq(number_of_connections)
        end
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
  let(:user) { FactoryGirl.create(:user, password_set: false) }
  let(:new_password) { Faker::Lorem.characters(15) }
  let(:raw_token) { user.send_reset_password_instructions }

  before { raw_token }

  it 'resets the User\'s password' do
    post_endpoint reset_password_token: raw_token,
                  password: new_password

    expect_success

    user.reload
    expect(user.valid_password?(new_password)).to be_true
    expect(user.password_set).to be_true
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
