require 'spec_helper'

describe 'Authentications API Methods' do
  describe 'GET /authentications authentications#index' do
    let(:endpoint) { '/authentications' }
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

    context 'invalid api_key' do
      let(:current_user) { nil }
      it 'returns an unauthorized error' do
        get_endpoint api_key: '1:234567890'

        expect_failure
        expect_status 401
      end
    end
  end

  describe 'POST /authentications authentications#create' do
    let(:endpoint) { '/authentications' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:screen_name) { 'eatmorsel' }
    let(:token) { 'token' }
    let(:secret) { 'secret' }

    context 'Twitter' do
      it 'creates a new Twitter authentication' do
        stub_twitter_client
        post_endpoint authentication: {
                        provider: 'twitter',
                        uid: 'twitter_user_id',
                        token: token,
                        secret: secret
                      }

        expect_success
        expect_json_data_eq({
          'uid' => 'twitter_user_id',
          'provider' => 'twitter',
          'secret' => secret,
          'token' => token,
          'user_id' => current_user.id,
          'name' => screen_name
        })

        twitter_authenticated_user = TwitterAuthenticatedUserDecorator.new(current_user)
        expect(twitter_authenticated_user.twitter_authentications.count).to eq(1)
        expect(twitter_authenticated_user.twitter_username).to eq(screen_name)
      end

      context 'Twitter friends already on Morsel' do
        context 'auto_follow=true' do
          before do
            current_user.auto_follow = 'true'
            current_user.save
          end

          let(:number_of_connections) { rand(2..6) }
          let(:stubbed_connections) do
            _stubbed_connections = []
            number_of_connections.times { _stubbed_connections << Faker::Number.number(rand(5..10)) }
            _stubbed_connections
          end

          it 'finds and follows any Twitter friends on Morsel' do
            stubbed_connections.each do |c|
              FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
            end
            stub_twitter_client(connections: stubbed_connections)

            Sidekiq::Testing.inline! do
              post_endpoint authentication: {
                            provider: 'twitter',
                            uid: 'twitter_uid',
                            token: 'token',
                            secret: 'secret'
                          }
            end

            expect_success

            expect(current_user.followed_user_count).to eq(number_of_connections)
          end
        end

        context 'auto_follow=false' do
          before do
            current_user.auto_follow = 'false'
            current_user.save
          end

          let(:number_of_connections) { rand(2..6) }
          let(:stubbed_connections) do
            _stubbed_connections = []
            number_of_connections.times { _stubbed_connections << Faker::Number.number(rand(5..10)) }
            _stubbed_connections
          end

          it 'finds and follows any Twitter friends on Morsel' do
            stubbed_connections.each do |c|
              FactoryGirl.create(:twitter_authentication, uid: c, name: Faker::Name.name)
            end
            stub_twitter_client(connections: stubbed_connections)

            Sidekiq::Testing.inline! do
              post_endpoint authentication: {
                            provider: 'twitter',
                            uid: 'twitter_uid',
                            token: 'token',
                            secret: 'secret'
                          }
            end

            expect_success
            expect(current_user.followed_user_count).to be_zero
          end
        end
      end
    end

    context 'Instagram' do
      it 'creates a new Instagram authentication' do
        stub_instagram_client
        post_endpoint authentication: {
                        provider: 'instagram',
                        uid: 'instagram_user_id',
                        token: token,
                        secret: secret
                      }

        expect_success
        expect_json_data_eq({
          'uid' => 'instagram_user_id',
          'provider' => 'instagram',
          'secret' => secret,
          'token' => token,
          'user_id' => current_user.id,
          'name' => screen_name
        })

        instagram_authenticated_user = InstagramAuthenticatedUserDecorator.new(current_user)
        expect(instagram_authenticated_user.instagram_authentications.count).to eq(1)
        expect(instagram_authenticated_user.instagram_username).to eq(screen_name)
      end

      context 'Instagram friends already on Morsel' do
        context 'auto_follow=true' do
          before do
            current_user.auto_follow = 'true'
            current_user.save
          end

          let(:number_of_connections) { rand(2..6) }
          let(:stubbed_connections) do
            _stubbed_connections = []
            number_of_connections.times { _stubbed_connections << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
            _stubbed_connections
          end

          it 'finds and follows any Instagram friends on Morsel' do
            stubbed_connections.each do |c|
              FactoryGirl.create(:instagram_authentication, uid: c['id'], name: c['name'])
            end
            stub_instagram_client(connections: stubbed_connections)

            Sidekiq::Testing.inline! do
              post_endpoint authentication: {
                            provider: 'instagram',
                            uid: 'instagram_uid',
                            token: 'token'
                          }
            end

            expect_success

            expect(current_user.followed_user_count).to eq(number_of_connections)
          end
        end

        context 'auto_follow=false' do
          before do
            current_user.auto_follow = 'false'
            current_user.save
          end

          let(:number_of_connections) { rand(2..6) }
          let(:stubbed_connections) do
            _stubbed_connections = []
            number_of_connections.times { _stubbed_connections << { 'id' => Faker::Number.number(rand(5..10)), 'name' => Faker::Name.name }}
            _stubbed_connections
          end

          it 'finds and follows any Instagram friends on Morsel' do
            stubbed_connections.each do |c|
              FactoryGirl.create(:instagram_authentication, uid: c['id'], name: c['name'])
            end
            stub_instagram_client(connections: stubbed_connections)

            Sidekiq::Testing.inline! do
              post_endpoint authentication: {
                            provider: 'instagram',
                            uid: 'instagram_uid',
                            token: 'token'
                          }
            end

            expect_success
            expect(current_user.followed_user_count).to be_zero
          end
        end
      end
    end

    context 'Facebook' do
      context 'short-lived token is passed' do
        let(:short_lived_token) { 'short_lived_token' }

        it 'exchanges for a new token' do
          stub_facebook_client
          stub_facebook_oauth(short_lived_token)

          post_endpoint authentication: {
                          provider: 'facebook',
                          uid: 'facebook_uid',
                          token: short_lived_token,
                          short_lived: true
                        }

          expect_success
          expect_json_data_eq('token' => 'new_access_token')
        end
      end

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

        post_endpoint authentication: {
                        provider: 'facebook',
                        uid: 'facebook_uid',
                        token: dummy_token
                      }

        expect_success

        expect_json_data_eq ({
          'uid' => dummy_fb_uid,
          'provider' => 'facebook',
          'secret' => nil,
          'token' => dummy_token,
          'user_id' => current_user.id,
          'name' => dummy_name
        })

        facebook_authenticated_user = FacebookAuthenticatedUserDecorator.new(current_user)
        expect(facebook_authenticated_user.facebook_authentications.count).to eq(1)
        expect(facebook_authenticated_user.facebook_uid).to eq(dummy_fb_uid)
      end

      context 'Facebook friends already on Morsel' do
        context 'auto_follow=true' do
          before do
            current_user.auto_follow = 'true'
            current_user.save
          end

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
              post_endpoint authentication: {
                            provider: 'facebook',
                            uid: 'facebook_uid',
                            token: 'token'
                          }
            end

            expect_success

            expect(current_user.followed_user_count).to eq(number_of_connections)
          end
        end

        context 'auto_follow=false' do
          before do
            current_user.auto_follow = 'false'
            current_user.save
          end

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
              post_endpoint authentication: {
                            provider: 'facebook',
                            uid: 'facebook_uid',
                            token: 'token'
                          }
            end

            expect_success
            expect(current_user.followed_user_count).to be_zero
          end
        end
      end
    end
  end

  describe 'PUT /authentications authentications#update' do
    let(:endpoint) { "/authentications/#{authentication.id}" }
    let(:current_user) { FactoryGirl.create(:chef_with_facebook_authentication) }
    let(:screen_name) { 'eatmorsel' }
    let(:authentication) { current_user.authentications.first }
    let(:token) { 'token' }
    let(:secret) { 'secret' }

    context 'Facebook' do
      it 'updates the authentication' do
        new_token = 'new_token'

        stub_facebook_client(id: authentication.uid)
        put_endpoint authentication: { token: new_token }
        expect_success
        expect_json_data_eq({
          'token' => new_token
        })

        authentication.reload
        expect(authentication.token).to eq(new_token)
      end
    end
  end

  describe 'DELETE /authentications/:id authentications#destroy' do
    let(:endpoint) { "/authentications/#{authentication.id}" }
    let(:current_user) { FactoryGirl.create(:chef_with_facebook_authentication) }
    let(:authentication) { current_user.authentications.first }

    it 'destroys the authentication for the current_user' do
      delete_endpoint

      expect_success
      expect(Authentication.find_by(id: authentication.id)).to be_nil
    end
  end

  describe 'GET /authentications/check authentications#check' do
    let(:endpoint) { '/authentications/check' }

    it 'returns false' do
      get_endpoint  authentication: {
                      provider: 'facebook',
                      uid: 1234
                    }

      expect_success
      expect_false_json_data
    end

    context 'Authentication exists' do
      let(:facebook_authentication) { FactoryGirl.create(:facebook_authentication) }

      it 'returns true' do
        get_endpoint  authentication: {
                        provider: facebook_authentication.provider,
                        uid: facebook_authentication.uid
                      }

        expect_success
        expect_true_json_data
      end
    end
  end

  describe 'POST /authentications/connections authentications#connections' do
    let(:endpoint) { '/authentications/connections' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:authenticated_users_count) { rand(2..6) }

    before { authenticated_users_count.times { FactoryGirl.create(:facebook_authentication) }}

    it 'returns no Users if none with the specified Authentications `uids` for the `provider` are found' do
      post_endpoint provider: 'facebook', uids: "'123','456','789'"

      expect_success
      expect_json_data_count 0
    end
  end
end
