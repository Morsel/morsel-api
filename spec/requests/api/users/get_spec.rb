require_relative '_spec_helper'

describe 'GET /users/me users#me' do
  let(:endpoint) { '/users/me' }
  let(:current_user) { FactoryGirl.create(:user) }

  it_behaves_like 'PresignedPhotoUploadable' do
    let(:presigned_photo_uploadable_object) {
      {
        api_key: api_key_for_user(current_user)
      }
    }
    let(:endpoint_method) { :get }
  end

  it 'returns the authenticated User' do
    get_endpoint

    expect_success
    expect_json_keys(json_data, current_user, %w(id username first_name last_name sign_in_count bio staff email password_set))
  end

  context 'has a Morsel draft' do
    let(:current_user) { FactoryGirl.create(:user_with_morsels) }
    before do
      current_user.morsels.first.update(draft: true)
    end

    it 'returns 1 for draft_count' do
      get_endpoint

      expect_success
      expect_json_data_eq('draft_count' => 1)
    end
  end

  context 'invalid api_key' do
    let(:current_user) { nil }
    it 'returns an unauthorized error' do
      get_endpoint api_key: '1:234567890'

      expect_failure
      expect_status 401
    end
  end
end

describe 'GET /users/:id|:username users#show' do
  let(:endpoint) { "/users/#{user_with_morsels.id}" }
  let(:user_with_morsels) { FactoryGirl.create(:user_with_morsels) }
  let(:number_of_likes) { rand(2..6) }

  before { number_of_likes.times { Like.create(likeable: FactoryGirl.create(:item_with_creator), liker: user_with_morsels) }}

  it 'returns the User' do
    get_endpoint

    expect_success
    expect_json_data_eq({
      'id' => user_with_morsels.id,
      'username' => user_with_morsels.username,
      'first_name' => user_with_morsels.first_name,
      'last_name' => user_with_morsels.last_name,
      'bio' => user_with_morsels.bio,
      'industry' => user_with_morsels.industry,
      'email' => nil,
      'password' => nil,
      'encrypted_password' => nil,
      'photos' => nil,
      'facebook_uid' => FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid,
      'twitter_username' => TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username
    })
  end

  context 'username passed instead of id' do
    let(:endpoint) { "/users/#{user_with_morsels.username}" }
    it 'returns the User' do
      get_endpoint

      expect_success
      expect_json_data_eq({
        'id' => user_with_morsels.id,
        'username' => user_with_morsels.username,
        'first_name' => user_with_morsels.first_name,
        'last_name' => user_with_morsels.last_name,
        'bio' => user_with_morsels.bio,
        'industry' => user_with_morsels.industry,
        'email' => nil,
        'password' => nil,
        'encrypted_password' => nil,
        'photos' => nil,
        'facebook_uid' => FacebookAuthenticatedUserDecorator.new(user_with_morsels).facebook_uid,
        'twitter_username' => TwitterAuthenticatedUserDecorator.new(user_with_morsels).twitter_username
      })
    end
  end

  context 'has a photo' do
    before do
      user_with_morsels.photo = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
      user_with_morsels.save
    end

    it 'returns the User with the appropriate image sizes' do
      get_endpoint

      expect_success

      photos = json_data['photos']
      expect(photos['_144x144']).to_not be_nil
      expect(photos['_72x72']).to_not be_nil
      expect(photos['_80x80']).to_not be_nil
      expect(photos['_40x40']).to_not be_nil
    end
  end

  context 'authenticated' do
    let(:current_user) { FactoryGirl.create(:user) }
    context('following another User(A)') do
      let(:endpoint) { "/users/#{followed_user.id}" }
      let(:followed_user) { FactoryGirl.create(:user) }
      before do
        Follow.create(followable: followed_user, follower: current_user)
      end

      it 'returns following=true' do
        get_endpoint

        expect_success
        expect_json_data_eq({
          'following' => true,
          'followed_user_count' => 0,
          'follower_count' => 1
        })
      end

      context 'User(A) is following another User(B)' do
        before do
          Follow.create(followable: FactoryGirl.create(:user), follower: followed_user)
        end

        it 'returns the correct following_count' do
          get_endpoint

          expect_success
          expect_json_data_eq({
            'followed_user_count' => 1,
            'follower_count' => 1
          })
        end
      end
    end
  end
end
