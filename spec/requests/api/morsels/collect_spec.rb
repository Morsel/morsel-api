require_relative '_spec_helper'

describe 'POST /morsels/{:morsel_id}/collect morsels#collect' do
  let(:endpoint) { "/morsels/#{morsel.id}/collect" }
  let(:current_user) { FactoryGirl.create(:user_with_collection) }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:collection) { current_user.collections.first }
  let(:note) { Faker::Lorem.sentence(rand(2..10)) }

  it 'adds the morsel to the collection' do
    post_endpoint collection_id: collection.id, note: note

    expect_success
    expect(collection.reload.morsels).to include(morsel)
    expect_json_data_eq({
      'id' => morsel.id,
      'note' => note,
      'sort_order' => 1
    })
  end

  context 'morsel is a draft' do
    let(:morsel) { FactoryGirl.create(:draft_morsel) }

    it 'should return an error' do
      post_endpoint collection_id: collection.id

      expect_failure
      expect_first_error('morsel', 'not published')
    end
  end

  context 'morsel already exists in the collection' do
    before { collection.morsels << morsel }

    it 'should return an error' do
      post_endpoint collection_id: collection.id

      expect_failure
      expect_first_error('morsel', 'already in this collection')
    end
  end

  context 'current_user is NOT the creator of the collection' do
    let(:someones_collection) { FactoryGirl.create(:collection) }
    it 'should return an error' do
      post_endpoint collection_id: someones_collection.id

      expect_failure
      expect_first_error('user', 'not authorized to add to this collection')
    end
  end
end

describe 'DELETE /morsels/{:morsel_id}/collect morsels#uncollect' do
  let(:endpoint) { "/morsels/#{morsel.id}/collect" }
  let(:current_user) { FactoryGirl.create(:user_with_collection) }
  let(:morsel) { FactoryGirl.create(:morsel_with_creator) }
  let(:collection) { current_user.collections.first }

  context 'morsel in collection' do
    before { collection.morsels << morsel }

    it 'removes the morsel from the collection' do
      delete_endpoint collection_id: collection.id

      expect_success
      expect(collection.reload.morsels).to_not include(morsel)
    end
  end

  context 'morsel does NOT exist in the collection' do
    it 'should return an error' do
      delete_endpoint collection_id: collection.id

      expect_failure
      expect_first_error('morsel', 'not in this collection')
    end
  end

  context 'current_user is NOT the creator of the collection' do
    let(:someones_collection) { FactoryGirl.create(:collection) }
    it 'should return an error' do
      delete_endpoint collection_id: someones_collection.id

      expect_failure
      expect_first_error('user', 'not authorized to remove from this collection')
    end
  end
end
