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
        let(:number_of_friends) { rand(2..6) }
        let(:stubbed_friends) do
          _stubbed_friends = []
          number_of_friends.times { _stubbed_friends << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
          _stubbed_friends
        end

        it 'finds and follows any Facebook friends on Morsel' do
          stubbed_friends.each do |c|
            FactoryGirl.create(:facebook_authentication, uid: c['id'], name: c['name'])
          end
          stub_facebook_client(friends: stubbed_friends)

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
          expect(new_user.followed_user_count).to eq(number_of_friends)
        end

        context 'followed users have auto_follow enabled' do
          it 'should follow them back' do
            stubbed_friends.each do |c|
              FactoryGirl.create(:facebook_authentication, uid: c['id'], name: c['name'])
            end
            stub_facebook_client(friends: stubbed_friends)
            first_authentication_user = Authentication.first.user
            first_authentication_user.update auto_follow: 'true'

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
            expect(first_authentication_user.followed_user_count).to eq(1)
          end
        end

        context 'followed users have auto_follow DISABLED' do
          it 'should follow them back' do
            stubbed_friends.each do |c|
              FactoryGirl.create(:facebook_authentication, uid: c['id'], name: c['name'])
            end
            stub_facebook_client(friends: stubbed_friends)
            first_authentication_user = Authentication.first.user
            first_authentication_user.update auto_follow: 'false'

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
            expect(first_authentication_user.followed_user_count).to eq(0)
          end
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
        let(:number_of_friends) { rand(2..6) }
        let(:stubbed_friends) do
          _stubbed_friends = []
          number_of_friends.times { _stubbed_friends << Faker::Number.number(rand(5..10)) }
          _stubbed_friends
        end

        it 'finds and follows any Twitter friends on Morsel' do
          stubbed_friends.each do |c|
            FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
          end
          stub_twitter_client(friends: stubbed_friends)

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
          expect(new_user.followed_user_count).to eq(number_of_friends)
        end

        context 'followed users have auto_follow enabled' do
          it 'should follow them back' do
            stubbed_friends.each do |c|
              FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
            end
            stub_twitter_client(friends: stubbed_friends, followers: stubbed_friends)
            first_authentication_user = Authentication.first.user
            first_authentication_user.update auto_follow: 'true'

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
            expect(first_authentication_user.followed_user_count).to eq(1)
          end
        end

        context 'followed users have auto_follow DISABLED' do
          it 'should follow them back' do
            stubbed_friends.each do |c|
              FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
            end
            stub_twitter_client(friends: stubbed_friends, followers: stubbed_friends)
            first_authentication_user = Authentication.first.user
            first_authentication_user.update auto_follow: 'false'

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
            expect(first_authentication_user.followed_user_count).to eq(0)
          end
        end
      end
    end
  end
end
