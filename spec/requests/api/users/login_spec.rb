require_relative '_spec_helper'

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

  context 'shadow_token' do
    let(:user) { FactoryGirl.create(:user) }
    let(:shadow_token) { Faker::Lorem.characters(32) }
    let(:redis_key) { "user_shadow_token/#{user.id}" }

    before do
      redis_set redis_key, shadow_token
    end

    it 'signs in the User' do
      post_endpoint({
        user_id: user.id,
        shadow_token: shadow_token
      })

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
