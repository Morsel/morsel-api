require 'spec_helper'

describe 'Keywords API' do
  describe 'GET /cuisines' do
    let(:endpoint) { '/cuisines' }
    let(:cuisines_count) { rand(3..6) }

    before { cuisines_count.times { FactoryGirl.create(:cuisine) }}

    it 'returns a list of Cuisines' do
      get_endpoint

      expect_success
      expect_json_data_count cuisines_count
    end
  end

  describe 'GET /specialties' do
    let(:endpoint) { '/specialties' }
    let(:specialties_count) { rand(3..6) }

    before { specialties_count.times { FactoryGirl.create(:specialty) }}

    it 'returns a list of Specialties' do
      get_endpoint

      expect_success
      expect_json_data_count specialties_count
    end
  end

  describe 'GET /keywords/:id/users' do
    let(:endpoint) { "/keywords/#{keyword.id}/users" }
    let(:keyword) { FactoryGirl.create(:keyword) }
    let(:users_count) { rand(3..6) }
    let(:tagger) { FactoryGirl.create(:user) }

    before { users_count.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: keyword) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: keyword) }
      end
    end

    it 'returns a list of Users for the specified keyword' do
      get_endpoint

      expect_success
      expect_json_data_count users_count
    end
  end

  describe 'GET /cuisines/:id/users' do
    let(:endpoint) { "/cuisines/#{cuisine.id}/users" }
    let(:cuisine) { FactoryGirl.create(:cuisine) }
    let(:users_count) { rand(3..6) }
    let(:tagger) { FactoryGirl.create(:user) }

    before { users_count.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: cuisine) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: cuisine) }
      end
    end

    it 'returns a list of Users for the specified cuisine' do
      get_endpoint

      expect_success
      expect_json_data_count users_count
    end
  end

  describe 'GET /specialties/:id/users' do
    let(:endpoint) { "/specialties/#{specialty.id}/users" }
    let(:specialty) { FactoryGirl.create(:specialty) }
    let(:users_count) { rand(3..6) }
    let(:tagger) { FactoryGirl.create(:user) }

    before { users_count.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: specialty) }}

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user_tag, tagger: tagger, keyword: specialty) }
      end
    end

    it 'returns a list of Users for the specified specialty' do
      get_endpoint

      expect_success
      expect_json_data_count users_count
    end
  end
end
