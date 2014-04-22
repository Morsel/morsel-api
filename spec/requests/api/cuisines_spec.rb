require 'spec_helper'

describe 'Cuisines API' do
  describe 'GET /cuisines' do
    let(:endpoint) { '/cuisines' }
    let(:cuisines_count) { 3 }

    before { cuisines_count.times { FactoryGirl.create(:cuisine) }}

    it 'returns a list of Cuisines' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(cuisines_count)

      expect_json_keys(json_data.first, Cuisine.first, %w(id name))
    end
  end

  describe 'GET /cuisines/:cuisine_id/users' do
    let(:cuisine) { FactoryGirl.create(:cuisine) }
    let(:endpoint) { "/cuisines/#{cuisine.id}/users" }
    let(:users_count) { 3 }

    before do
      users_count.times do
        user = FactoryGirl.create(:user)
        user.cuisines << cuisine
      end
    end

    it 'returns a list of Users with the specified cuisine' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(users_count)
    end
  end

  describe 'GET /users/:user_id/cuisines' do
    let(:user) { FactoryGirl.create(:user) }
    let(:endpoint) { "/users/#{user.id}/cuisines" }
    let(:cuisines_count) { 3 }

    before do
      cuisines_count.times do
        user.cuisines << FactoryGirl.create(:cuisine)
      end
    end

    it 'returns a list of Cuisines for the specified user' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(cuisines_count)

      expect_json_keys(json_data.first, Cuisine.first, %w(id name))
    end
  end
end
