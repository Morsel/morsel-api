require_relative '_spec_helper'

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
