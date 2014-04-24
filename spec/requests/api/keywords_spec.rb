require 'spec_helper'

describe 'Keywords API' do
  describe 'GET /cuisines' do
    let(:endpoint) { '/cuisines' }
    let(:cuisines_count) { rand(3..6) }

    before do
      cuisines_count.times { FactoryGirl.create(:cuisine) }
    end

    it 'returns a list of Cuisines' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(cuisines_count)
    end
  end

  describe 'GET /specialties' do
    let(:endpoint) { '/specialties' }
    let(:specialties_count) { rand(3..6) }

    before do
      specialties_count.times { FactoryGirl.create(:specialty) }
    end

    it 'returns a list of Specialties' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(specialties_count)
    end
  end

  describe 'GET /keywords/:id/users' do
    let(:endpoint) { "/keywords/#{keyword.id}/users" }
    let(:keyword) { FactoryGirl.create(:keyword) }
    let(:users_count) { rand(3..6) }

    before do
      users_count.times { FactoryGirl.create(:user_tag, keyword: keyword) }
    end

    it 'returns a list of Users for the specified keyword' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(users_count)
    end
  end

  describe 'GET /cuisines/:id/users' do
    let(:endpoint) { "/cuisines/#{cuisine.id}/users" }
    let(:cuisine) { FactoryGirl.create(:cuisine) }
    let(:users_count) { rand(3..6) }

    before do
      users_count.times { FactoryGirl.create(:user_tag, keyword: cuisine) }
    end

    it 'returns a list of Users for the specified cuisine' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(users_count)
    end
  end

  describe 'GET /specialties/:id/users' do
    let(:endpoint) { "/specialties/#{specialty.id}/users" }
    let(:specialty) { FactoryGirl.create(:specialty) }
    let(:users_count) { rand(3..6) }

    before do
      users_count.times { FactoryGirl.create(:user_tag, keyword: specialty) }
    end

    it 'returns a list of Users for the specified specialty' do
      get endpoint, format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(users_count)
    end
  end
end
