require_relative '_spec_helper'

describe 'GET /users/unsubscribe users#unsubscribe' do
  let(:endpoint) { '/users/unsubscribe' }
  let(:user) { FactoryGirl.create(:user) }

  it 'unsubscribes the user' do
    expect(user.unsubscribed).to be_false

    post_endpoint email: user.email

    expect_success
    user.reload
    expect(user.unsubscribed).to be_true
  end
end
