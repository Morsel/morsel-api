require_relative '_spec_helper'

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
    expect(user.active).to be_false
    expect(user.password_set).to be_false
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
