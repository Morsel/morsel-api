shared_examples 'TaggableController' do
  describe 'POST /taggable/:id/tags' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/tags" }
    it 'creates a Tag' do
      post endpoint, keyword_id: keyword.id, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
      expect(json_data['id']).to_not be_nil

      new_tag = Tag.find json_data['id']
      expect_json_keys(json_data, new_tag, %w(id taggable_id taggable_type))
      expect(json_data['keyword']['name']).to eq(new_tag.name)
    end
  end

  describe 'GET /taggable/:id/cuisines' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/cuisines" }
    let(:cuisine_tags_count) { rand(3..6) }

    before do
      cuisine_tags_count.times { taggable.tags << FactoryGirl.create(:user_cuisine_tag) }
    end

    it 'returns a list of Cuisine Tags for the taggable' do
      get endpoint, keyword_id: keyword.id, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(cuisine_tags_count)
    end
  end

  describe 'GET /taggable/:id/specialties' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/specialties" }
    let(:specialty_tags_count) { rand(3..6) }

    before do
      specialty_tags_count.times { taggable.tags << FactoryGirl.create(:user_specialty_tag) }
    end

    it 'returns a list of Specialty Tags for the taggable' do
      get endpoint, keyword_id: keyword.id, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
      expect(json_data.count).to eq(specialty_tags_count)
    end
  end

  describe 'DELETE /taggable/:id/tags/:tag_id' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/tags/#{tag.id}" }

    it 'soft deletes the Comment' do
      delete endpoint, api_key: api_key_for_user(user), format: :json

      expect(response).to be_success
      expect(Tag.find_by(id: tag.id)).to be_nil
    end
  end
end
