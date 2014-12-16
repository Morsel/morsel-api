require_relative '_spec_helper'

describe 'Collections API Methods' do
  describe 'GET /collections/:id collections#show' do
    let(:endpoint) { "/collections/#{collection.id}" }
    let(:collection) { FactoryGirl.create(:collection) }

    it 'returns the Collection' do
      get_endpoint

      expect_success
      expect_json_data_eq({
        'id' => collection.id,
        'title' => collection.title,
        'description' => collection.description,
        'user_id' => collection.user_id,
        'place_id' => collection.place_id,
        'slug' => collection.cached_slug
      })
    end
  end

  describe 'POST /collections collections#create' do
    let(:endpoint) { '/collections' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:title) { Faker::Lorem.sentence(rand(2..4)).truncate(70) }
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

  describe 'PUT /collections/:id collections#update' do
    let(:endpoint) { "/collections/#{collection.id}" }
    let(:current_user) { FactoryGirl.create(:user_with_collection) }
    let(:new_title) { Faker::Lorem.sentence(rand(2..4)).truncate(70) }
    let(:new_description) { Faker::Lorem.sentence(rand(2..10)) }
    let(:collection) { current_user.collections.first }

    it 'updates the collection' do
      put_endpoint collection: {
        title: new_title,
        description: new_description
      }
      expect_success

      expect_json_data_eq({
        'title' => new_title,
        'description' => new_description
      })

      collection.reload
      expect(collection.title).to eq(new_title)
      expect(collection.description).to eq(new_description)
    end
  end

  describe 'DELETE /collections/:id collections#destroy' do
    let(:endpoint) { "/collections/#{collection.id}" }
    let(:current_user) { FactoryGirl.create(:user_with_collection) }
    let(:collection) { current_user.collections.first }

    it 'destroys the collection for the current_user' do
      delete_endpoint

      expect_success
      expect(Collection.find_by(id: collection.id)).to be_nil
    end
  end

  describe 'GET /collections/:id/morsels collections#morsels' do
    let(:endpoint) { "/collections/#{collection.id}/morsels" }
    let(:collection) { FactoryGirl.create(:collection_with_morsels) }

    it_behaves_like 'PagePaginateable' do
      let(:paginateable_object_class) { CollectionMorsel }

      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:collection_morsel, collection: collection, morsel: FactoryGirl.create(:morsel_with_creator)) }
      end
    end

    it 'returns all morsels in the collection with `note`' do
      get_endpoint

      expect_success
      expect_json_data_count collection.morsels.count
      collection_morsel = collection.collection_morsels.first

      expect_first_json_data_eq({
        'note' => collection_morsel.note,
        'sort_order' => collection_morsel.sort_order
      })
    end
  end
end
