require_relative '_spec_helper'

describe 'POST /morsels/:id/tagged_users/:user_id' do
  let(:endpoint) { "/morsels/#{morsel.id}/tagged_users/#{user.id}" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  context 'current_user is the morsel creator' do
    let(:current_user) { morsel_creator }

    context 'User follows the morsel creator' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        morsel_creator.followers << user
      end

      it 'tags the User to the morsel' do
        post_endpoint

        expect_success

        expect(morsel.tagged_users).to include(user)
      end

      it 'does NOT create a Notification' do
        expect {
          post_endpoint
        }.to_not change(Notification.count, :size).by(1)
      end
    end

    context 'User does NOT follow the morsel creator' do
      let(:user) { FactoryGirl.create(:user) }

      it 'should return an error' do
        post_endpoint

        expect_failure

        expect_authority_error :create, MorselUserTag
      end
    end
  end

  context 'current_user is NOT the morsel creator' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should return an error' do
      post_endpoint

      expect_failure

      expect_authority_error :create, MorselUserTag
    end
  end
end

describe 'GET /morsels/:id/tagged_users' do
  let(:endpoint) { "/morsels/#{morsel.id}/tagged_users" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  let(:tagged_users_count) { rand(2..6) }

  before { tagged_users_count.times { FactoryGirl.create(:morsel_user_tag, morsel: morsel) }}

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { User }

    before do
      paginateable_object_class.delete_all
      30.times { |i| FactoryGirl.create(:morsel_user_tag, morsel: morsel) }
    end
  end

  it 'returns the Users that are tagged to the morsel' do
    get_endpoint

    expect_success

    expect_json_data_count tagged_users_count
  end

  context 'last User unfollowed Followable' do
    before { MorselUserTag.last.destroy }

    it 'returns one less tagged User' do
      get_endpoint

      expect_success
      expect_json_data_count(tagged_users_count - 1)
    end
  end
end

describe 'GET /morsels/:id/eligible_tagged_users' do
  let(:endpoint) { "/morsels/#{morsel.id}/eligible_tagged_users" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  let(:eligible_tagged_users_count) { rand(2..6) }

  before { eligible_tagged_users_count.times { |i| FactoryGirl.create(:user_follow, followable: morsel_creator, follower: FactoryGirl.create(:user), created_at:Time.at(i) + 1000) }}

  it_behaves_like 'TimelinePaginateable' do
    let(:paginateable_object_class) { User }

    before do
      paginateable_object_class.delete_all
      30.times { |i| FactoryGirl.create(:user_follow, followable: morsel_creator, follower: FactoryGirl.create(:user), created_at:Time.at(i) + 1000) }
    end
  end

  it 'returns the Users that are eligible to be tagged to the morsel' do
    get_endpoint

    expect_success

    expect_json_data_count eligible_tagged_users_count
    expect_first_json_data_eq({
      'tagged' => false
    })
  end

  context 'first eligible User is already tagged' do
    before { FactoryGirl.create(:morsel_user_tag, morsel: morsel, user: Follow.last.follower) }

    it 'returns `tagged`=true for that User' do
      get_endpoint

      expect_success

      expect_json_data_count eligible_tagged_users_count
      expect_first_json_data_eq({
        'tagged' => true
      })
    end
  end

  context 'last User unfollowed morsel creator' do
    before { Follow.last.destroy }

    it 'returns one less eligible User' do
      get_endpoint

      expect_success
      expect_json_data_count(eligible_tagged_users_count - 1)
    end
  end

  context 'query' do
    before { FactoryGirl.create(:user_follow, followable: morsel_creator, follower: FactoryGirl.create(:user, first_name: 'Arya', last_name: 'Stark')) }
    it 'returns eligible Users matching `first_name`, `last_name`, and `username`' do
      get_endpoint query: 'stark'

      expect_success
      expect_json_data_count 1
      expect(json_data.first['first_name']).to eq('Arya')
    end
  end
end

describe 'DELETE /morsels/:id/tagged_users/:user_id' do
  let(:endpoint) { "/morsels/#{morsel.id}/tagged_users/#{user.id}" }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:morsel_creator) { morsel.creator }

  context 'current_user is the morsel creator' do
    let(:current_user) { morsel_creator }
    let(:user) { FactoryGirl.create(:user) }

    before do
      morsel.tagged_users << user
    end

    it 'untags the User to the morsel' do
      delete_endpoint

      expect_success

      expect(morsel.tagged_users).to_not include(user)
    end
  end

  context 'current_user is NOT the morsel creator' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:user) { current_user }

    context 'current_user is tagged to the morsel' do
      before do
        morsel.tagged_users << current_user
      end

      it 'untags the User from the morsel' do
        delete_endpoint

        expect_success

        expect(morsel.tagged_users).to_not include(current_user)
      end
    end

    context 'User is NOT tagged to the morsel' do
      let(:current_user) { FactoryGirl.create(:user) }

      it 'should return an error' do
        delete_endpoint

        expect_failure

        expect_record_not_found_error
      end
    end
  end
end
