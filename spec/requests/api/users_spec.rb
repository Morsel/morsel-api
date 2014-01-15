require 'spec_helper'

describe 'Users API' do
  describe 'POST /api/users registrations#create' do
    it 'creates a new User' do
      post '/api/users', format: :json, user: { email: 'foo@bar.com', password: 'password',
                                                first_name: 'Foo', last_name: 'Bar' }

      expect(response).to be_success

      expect(json['id']).to_not be_nil

      new_user = User.find json['id']
      expect_json_keys(json, new_user, %w(id first_name last_name sign_in_count photo_url title))
      expect(json['auth_token']).to eq(new_user.authentication_token)
      expect_nil_json_keys(json, %w(password encrypted_password))
    end
  end

  describe 'POST /api/users/sign_in sessions#create' do
    before do
      @user = FactoryGirl.create(:user)
    end
    it 'signs in the User' do
      post '/api/users/sign_in', format: :json, user: { email: @user.email, password: 'password' }

      expect(response).to be_success

      expect_json_keys(json, @user, %w(id first_name last_name photo_url title))
      expect(json['auth_token']).to eq(@user.authentication_token)
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
    before do
      @user = FactoryGirl.create(:turd_ferg)
    end

    it 'returns the User' do
      get "/api/users/#{@user.id}", api_key: @user.id, format: :json

      expect(response).to be_success

      expect_json_keys(json, @user, %w(id first_name last_name sign_in_count photo_url title))
      expect_nil_json_keys(json, %w(password encrypted_password auth_token))
    end
  end

  describe 'PUT /api/users/{:user_id users#update' do
    before do
      @user = FactoryGirl.create(:turd_ferg)
    end

    it 'updates the User' do
      new_first_name = 'Bob'

      put "/api/users/#{@user.id}", api_key: @user.id, format: :json, user: { first_name: new_first_name }

      expect(response).to be_success

      expect(json['first_name']).to eq(new_first_name)
      expect(User.first.first_name).to eq(new_first_name)
    end
  end

  describe 'GET /api/users/{:user_id}/posts' do
    before do
      @user = FactoryGirl.create(:user_with_posts)
    end

    it 'returns all of the User\'s  Posts' do
      get "/api/users/#{@user.id}/posts", api_key: @user.id, format: :json

      expect(response).to be_success

      expect(json.count).to eq(@user.posts.count)
    end
  end
end
