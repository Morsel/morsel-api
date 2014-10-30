require_relative '_spec_helper'

describe 'PUT /users/:id users#update' do
  let(:endpoint) { "/users/#{current_user.id}" }
  let(:current_user) { FactoryGirl.create(:user) }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:presigned_photo_uploadable_object) {
      {
        user: {
          first_name: 'Foo'
        }
      }
    }
    let(:endpoint_method) { :put }
  end

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

    it 'fails if `current_password` is invalid' do
      put_endpoint user: { email: new_email, current_password: 'butts' }

      expect_failure
      expect(json_errors['current_password']).to include('is invalid')
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

    it 'fails if `current_password` is invalid' do
      put_endpoint user: { username: new_username, current_password: 'butts' }

      expect_failure
      expect(json_errors['current_password']).to include('is invalid')
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

    it 'fails if `current_password` is invalid' do
      put_endpoint user: { password: new_password, current_password: 'butts' }

      expect_failure
      expect(json_errors['current_password']).to include('is invalid')
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
