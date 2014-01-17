require 'spec_helper'

describe 'Users API' do
  describe 'POST /api/users registrations#create' do
    it 'creates a new User' do
      post '/api/users', format: :json, user: { email: 'foo@bar.com', password: 'password',
                                                first_name: 'Foo', last_name: 'Bar' }

      expect(response).to be_success

      expect(json['id']).to_not be_nil

      new_user = User.find json['id']
      expect_json_keys(json, new_user, %w(id first_name last_name sign_in_count title))
      expect(json['auth_token']).to eq(new_user.authentication_token)
      expect(json['photo_url']).to eq(new_user.photo_url)
      expect_nil_json_keys(json, %w(password encrypted_password))
    end
  end

  describe 'POST /api/users/sign_in sessions#create' do
    let(:user) { FactoryGirl.create(:user) }

    it 'signs in the User' do
      post '/api/users/sign_in', format: :json, user: { email: user.email, password: 'password' }

      expect(response).to be_success

      expect_json_keys(json, user, %w(id first_name last_name title))
      expect(json['auth_token']).to eq(user.authentication_token)
      expect(json['photo_url']).to eq(user.photo_url)
      expect(json['sign_in_count']).to eq(1)
      expect_nil_json_keys(json, %w(password encrypted_password))
    end
  end

  # Undocumented method
  describe 'GET /api/users users#index' do
    before do
      3.times { FactoryGirl.create(:user) }
    end

    it 'returns a list of Users' do
      get '/api/users', api_key: User.first.id, format: :json

      expect(response).to be_success

      expect(json.count).to eq(3)
    end
  end

  describe 'GET /api/users/{:user_id} users#show' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'returns the User' do
      get "/api/users/#{turd_ferg.id}", api_key: turd_ferg.id, format: :json

      expect(response).to be_success

      expect_json_keys(json, turd_ferg, %w(id first_name last_name sign_in_count title))
      expect_nil_json_keys(json, %w(password encrypted_password auth_token))

      expect(json['photo_url']).to eq(turd_ferg.photo_url)
    end
  end

  describe 'PUT /api/users/{:user_id} users#update' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put "/api/users/#{turd_ferg.id}", api_key: turd_ferg.id, format: :json, user: { first_name: new_first_name }

      expect(response).to be_success

      expect(json['first_name']).to eq(new_first_name)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /api/users/{:user_id}/posts' do
    let(:user_with_posts) { FactoryGirl.create(:user_with_posts) }

    it 'returns all of the User\'s  Posts' do
      get "/api/users/#{user_with_posts.id}/posts", api_key: user_with_posts.id, format: :json

      expect(response).to be_success

      expect(json.count).to eq(user_with_posts.posts.count)
    end
  end

  describe 'GET /api/users/{:user_id}/authorizations' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'returns the User\'s Authorizations' do
      get "/api/users/#{turd_ferg.id}/authorizations", api_key: turd_ferg.id, format: :json

      expect(response).to be_success
    end
  end

  describe 'POST /api/users/{:user_id}/authorizations' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

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

        post "api/users/#{turd_ferg.id}/authorizations", api_key: turd_ferg.id,
                                                     provider: 'twitter',
                                                     token: dummy_token,
                                                     secret: dummy_secret,
                                                     format: :json

        expect(response).to be_success

        expect(json['id']).to_not be_nil
        expect(json['provider']).to eq('twitter')
        expect(json['secret']).to eq(dummy_secret)
        expect(json['token']).to eq(dummy_token)
        expect(json['user_id']).to eq(turd_ferg.id)
        expect(json['name']).to eq(dummy_screen_name)

        expect(turd_ferg.twitter_authorizations.count).to eq(1)
      end
    end
  end
end
