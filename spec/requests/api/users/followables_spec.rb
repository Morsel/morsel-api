require_relative '_spec_helper'

describe 'GET /users/:id/followables' do
  context 'type=Keyword' do
    let(:endpoint) { "/users/#{follower.id}/followables?type=Keyword" }
    let(:follower) { FactoryGirl.create(:user) }
    let(:followed_keywords_count) { rand(2..6) }

    before do
      followed_keywords_count.times { |i| FactoryGirl.create(:keyword_follow, followable: FactoryGirl.create(:cuisine), follower: follower, created_at:Time.at(i) + 1000) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Follow }
      let(:paginateable_key) { :created_at }
      let(:paginateable_response_key) { :followed_at }

      before do
        paginateable_object_class.delete_all
        30.times { |i| FactoryGirl.create(:keyword_follow, follower: follower, created_at:Time.at(i) + 1000) }
      end
    end

    it 'returns the Keywords that the User has followed' do
      get_endpoint

      expect_success

      expect_json_data_count followed_keywords_count
      expect_first_json_data_eq('followed_at' => Follow.last.created_at.as_json)
    end

    context 'unfollowed last Keyword' do
      before do
        Follow.last.destroy
      end
      it 'returns one less followed user' do
        get_endpoint

        expect_success
        expect_json_data_count(followed_keywords_count - 1)
      end
    end
  end

  context 'type=User' do
    let(:endpoint) { "/users/#{follower.id}/followables?type=User" }
    let(:follower) { FactoryGirl.create(:user) }
    let(:followed_users_count) { rand(2..6) }

    before do
      followed_users_count.times { |i| FactoryGirl.create(:user_follow, followable: FactoryGirl.create(:user), follower: follower, created_at:Time.at(i) + 1000) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Follow }
      let(:paginateable_key) { :created_at }
      let(:paginateable_response_key) { :followed_at }

      before do
        paginateable_object_class.delete_all
        30.times { |i| FactoryGirl.create(:user_follow, follower: follower, created_at:Time.at(i) + 1000) }
      end
    end

    it 'returns the Users that the User has followed' do
      get_endpoint

      expect_success
      expect_json_data_count followed_users_count
      expect_first_json_data_eq('followed_at' => Follow.last.created_at.as_json)
    end

    context 'unfollowed last User' do
      before do
        Follow.last.destroy
      end
      it 'returns one less followed user' do
        get_endpoint

        expect_success
        expect_json_data_count(followed_users_count - 1)
      end
    end
  end
end
