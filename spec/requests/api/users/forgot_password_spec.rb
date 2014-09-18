require_relative '_spec_helper'

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
