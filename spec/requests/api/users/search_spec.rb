require_relative '_spec_helper'

describe 'GET /users/search users#search' do
  let(:endpoint) { '/users/search' }

  context 'query' do
    before do
      FactoryGirl.create(:user, first_name: 'TURd')
      FactoryGirl.create(:user, last_name: 'tURD')
      FactoryGirl.create(:user, username: 'turdski')
    end

    it 'returns Users matching `first_name`, `last_name`, and `username`' do
      get_endpoint  user: {
                            query: 'turd'
                          }

      expect_success
      expect_json_data_count 3
      expect(json_data.first['following']).to be_false
    end

    it 'returns fuzzy begins with matches' do
      get_endpoint  user: {
                            query: 'tur'
                          }

      expect_success
      expect_json_data_count 3
      expect(json_data.first['following']).to be_false
    end
  end

  context 'promoted' do
    let(:promoted_users_count) { rand(2..6) }
    before do
      promoted_users_count.times { FactoryGirl.create(:user, promoted: true) }
      rand(1..3).times { FactoryGirl.create(:user) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { User }
      let(:additional_params) {{ user: { promoted: true }}}

      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:user, promoted: true) }
      end
    end

    it 'returns `promoted` Users' do
      get_endpoint  user: {
                      promoted: true
                    }

      expect_success
      expect_json_data_count promoted_users_count
    end
  end

  context 'first_name' do
    let(:users_first_named_turd_count) { rand(2..6) }
    before do
      users_first_named_turd_count.times { FactoryGirl.create(:user, first_name: 'Turd') }
      rand(1..3).times { FactoryGirl.create(:user) }
    end

    it 'returns Users matching `first_name`' do
      get_endpoint  user: {
                      first_name: 'Turd'
                    }

      expect_success
      expect_json_data_count users_first_named_turd_count
    end

    it 'is case insensitive' do
      get_endpoint  user: {
                      first_name: 'tURD'
                    }

      expect_success
      expect_json_data_count users_first_named_turd_count
    end
  end

  context 'last_name' do
    let(:users_last_named_ferguson_count) { rand(2..6) }
    before do
      users_last_named_ferguson_count.times { FactoryGirl.create(:user, last_name: 'Turd') }
      rand(1..3).times { FactoryGirl.create(:user) }
    end

    it 'returns Users matching `last_name`' do
      get_endpoint  user: {
                      last_name: 'Turd'
                    }

      expect_success
      expect_json_data_count users_last_named_ferguson_count
    end
  end

  context 'first_name and last_name' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      rand(1..3).times { FactoryGirl.create(:user) }
    end

    context '`current_user` is following `user`' do
      let(:current_user) { FactoryGirl.create(:user) }
      before do
        Follow.create(followable: user, follower: current_user)
      end

      it 'returns `following` true' do
        get_endpoint  user: {
                        first_name: user.first_name,
                        last_name: user.last_name
                      }

        expect_success
        expect(json_data.first['following']).to be_true
      end
    end

    it 'returns Users matching `first_name` and `last_name`' do
      get_endpoint  user: {
                      first_name: user.first_name,
                      last_name: user.last_name
                    }

      expect_success
      expect_json_data_count 1
    end
  end
end
