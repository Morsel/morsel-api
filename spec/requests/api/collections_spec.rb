require 'spec_helper'

describe 'Collections API Methods' do
  describe 'POST /collections collections#create' do
    let(:endpoint) { '/collections' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:title) { Faker::Lorem.sentence(rand(2..4)).truncate(50) }
    let(:description) { Faker::Lorem.sentence(rand(2..10)) }

    it 'creates a new collection' do
      post_endpoint collection: {
                      title: title,
                      description: description
                    }

      expect_success
      expect_json_data_eq({
        'user_id' => current_user.id,
        'title' => title,
        'description' => description
      })
    end
  end
end
