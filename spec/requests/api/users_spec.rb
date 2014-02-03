require 'spec_helper'

describe 'Users API' do
  describe 'POST /users registrations#create' do
    it 'creates a new User' do
      post '/users', format: :json, user: { email: 'foo@bar.com', password: 'password',
                                            first_name: 'Foo', last_name: 'Bar', username: 'foobar',
                                            bio: 'Foo to the Stars' }

      expect(response).to be_success

      expect(json_data['id']).to_not be_nil

      new_user = User.find json_data['id']
      expect_json_keys(json_data, new_user, %w(id username first_name last_name sign_in_count title bio))
      expect(json_data['auth_token']).to eq(new_user.authentication_token)
      expect(json_data['photos']).to be_nil
      expect_nil_json_keys(json_data, %w(password encrypted_password))
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
    before do
      3.times { FactoryGirl.create(:user) }
    end

    it 'returns a list of Users' do
      get '/users', api_key: User.first.id, format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(3)
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
      get "/users/#{user_with_posts.id}", api_key: user_with_posts.id, format: :json

      expect(response).to be_success

      expect_json_keys(json_data, user_with_posts, %w(id username first_name last_name sign_in_count title bio))
      expect_nil_json_keys(json_data, %w(password encrypted_password auth_token))

      expect(json_data['photos']).to be_nil
      expect(json_data['twitter_username']).to eq(user_with_posts.twitter_username)

      expect(json_data['like_count']).to eq(number_of_morsel_likes)
      expect(json_data['morsel_count']).to eq(user_with_posts.morsels.count)
      expect(json_data['draft_count']).to eq(user_with_posts.morsels.drafts.count)
    end

    context 'username passed instead of id' do
      it 'returns the User' do
        get "/users/#{user_with_posts.username}", api_key: user_with_posts.id, format: :json

        expect(response).to be_success

        expect_json_keys(json_data, user_with_posts, %w(id username first_name last_name sign_in_count title bio))
        expect_nil_json_keys(json_data, %w(password encrypted_password auth_token))

        expect(json_data['photos']).to be_nil
        expect(json_data['twitter_username']).to eq(user_with_posts.twitter_username)

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
        get "/users/#{user_with_posts.id}", api_key: user_with_posts.id, format: :json

        expect(response).to be_success

        photos = json_data['photos']
        expect(photos['_144x144']).to_not be_nil
        expect(photos['_72x72']).to_not be_nil
        expect(photos['_80x80']).to_not be_nil
        expect(photos['_40x40']).to_not be_nil
      end
    end

    context 'has a Morsel draft' do
      before do
        first_morsel = user_with_posts.morsels.first
        first_morsel.draft = true
        first_morsel.save
      end

      it 'returns 1 for draft_count' do
        get "/users/#{user_with_posts.id}", api_key: user_with_posts.id, format: :json

        expect(response).to be_success

        expect(json_data['draft_count']).to eq(1)
      end
    end
  end

  describe 'PUT /users/{:user_id} users#update' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'updates the User' do
      new_first_name = 'Bob'

      put "/users/#{turd_ferg.id}", api_key: turd_ferg.id, format: :json, user: { first_name: new_first_name }

      expect(response).to be_success

      expect(json_data['first_name']).to eq(new_first_name)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /users/{:user_id|user_username}/posts' do
    let(:user_with_posts) { FactoryGirl.create(:user_with_posts) }

    it 'returns all of the User\'s  Posts' do
      get "/users/#{user_with_posts.id}/posts", api_key: user_with_posts.id, format: :json

      expect(response).to be_success

      expect(json_data.count).to eq(user_with_posts.posts.count)
    end

    context 'username passed instead of id' do
      it 'returns all of the User\'s  Posts' do
        get "/users/#{user_with_posts.username}/posts", api_key: user_with_posts.id, format: :json

        expect(response).to be_success

        expect(json_data.count).to eq(user_with_posts.posts.count)
      end
    end

    context 'include_drafts=true included in parameters' do
      it 'returns all of the User\'s  Posts including Morsel drafts' do
        get "/users/#{user_with_posts.id}/posts", api_key: user_with_posts.id,
                                                  format: :json,
                                                  include_drafts: true

        expect(response).to be_success

        expect(json_data.count).to eq(user_with_posts.posts.count)
      end
    end
  end

  describe 'GET /users/{:user_id}/authorizations' do
    let(:turd_ferg) { FactoryGirl.create(:turd_ferg) }

    it 'returns the User\'s Authorizations' do
      get "/users/#{turd_ferg.id}/authorizations", api_key: turd_ferg.id, format: :json

      expect(response).to be_success
    end
  end

  describe 'POST /users/{:user_id}/authorizations' do
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

        post "/users/#{turd_ferg.id}/authorizations", api_key: turd_ferg.id,
                                                      provider: 'twitter',
                                                      token: dummy_token,
                                                      secret: dummy_secret,
                                                      format: :json

        expect(response).to be_success

        expect(json_data['id']).to_not eq(123)
        expect(json_data['provider']).to eq('twitter')
        expect(json_data['secret']).to eq(dummy_secret)
        expect(json_data['token']).to eq(dummy_token)
        expect(json_data['user_id']).to eq(turd_ferg.id)
        expect(json_data['name']).to eq(dummy_screen_name)

        expect(turd_ferg.twitter_authorizations.count).to eq(1)
      end
    end

    context 'Facebook' do
      it 'creates a new Facebook authorization' do
        dummy_name = 'Facebook User'
        dummy_token = 'token'
        client = double('Koala::Facebook::API')
        Koala::Facebook::API.stub(:new).and_return(client)
        facebook_user = double('Hash')
        facebook_user.stub(:[]).with('id').and_return(123)
        facebook_user.stub(:[]).with('name').and_return(dummy_name)
        facebook_user.stub(:[]).with('link').and_return("https://facebook.com/#{dummy_name}")

        client.stub(:get_object).and_return(facebook_user)

        post "/users/#{turd_ferg.id}/authorizations", api_key: turd_ferg.id,
                                                      provider: 'facebook',
                                                      token: dummy_token,
                                                      format: :json

        expect(response).to be_success

        expect(json_data['id']).to_not eq(123)
        expect(json_data['provider']).to eq('facebook')
        expect(json_data['secret']).to be_nil
        expect(json_data['token']).to eq(dummy_token)
        expect(json_data['user_id']).to eq(turd_ferg.id)
        expect(json_data['name']).to eq(dummy_name)

        expect(turd_ferg.facebook_authorizations.count).to eq(1)
      end
    end
  end
end
