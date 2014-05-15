shared_examples 'TaggableController' do
  describe 'POST /taggable/:id/tags' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/tags" }
    it 'creates a Tag' do
      post_endpoint tag: {
                      keyword_id: keyword.id
                    }

      expect_success
      new_tag = Tag.find json_data['id']
      expect_json_data_eq({
        'id' => new_tag.id,
        'taggable_id' => new_tag.taggable_id,
        'taggable_type' => new_tag.taggable_type,
        'keyword' => { 'name' => new_tag.name }
      })
    end

    context 'keyword_id is omitted' do
      it 'returns an error' do
        post_endpoint tag: {}

        expect_failure
      end
    end
  end

  describe 'GET /taggable/:id/cuisines' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/cuisines" }
    let(:cuisine_tags_count) { rand(3..6) }

    before do
      cuisine_tags_count.times { taggable.tags << FactoryGirl.create(:user_cuisine_tag) }
    end

    it 'returns a list of Cuisine Tags for the taggable' do
      get_endpoint  keyword_id: keyword.id

      expect_success
      expect_json_data_count cuisine_tags_count
    end
  end

  describe 'GET /taggable/:id/specialties' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/specialties" }
    let(:specialty_tags_count) { rand(3..6) }

    before do
      specialty_tags_count.times { taggable.tags << FactoryGirl.create(:user_specialty_tag) }
    end

    it 'returns a list of Specialty Tags for the taggable' do
      get_endpoint  keyword_id: keyword.id

      expect_success
      expect_json_data_count specialty_tags_count
    end
  end

  describe 'DELETE /taggable/:id/tags/:tag_id' do
    let(:endpoint) { "#{taggable_route}/#{taggable.id}/tags/#{existing_tag.id}" }

    it 'soft deletes the Comment' do
      delete_endpoint

      expect_success
      expect(Tag.find_by(id: existing_tag.id)).to be_nil
    end

    context 'Tag doesn\'t exist' do
      let(:new_tag) { FactoryGirl.build(:user_tag, tagger: current_user, id: 10000) }
      let(:endpoint) { "#{taggable_route}/#{taggable.id}/tags/#{new_tag.id}" }

      it 'returns an error' do
        delete_endpoint

        expect_failure
        expect(json_errors['base']).to include('Record not found')
      end
    end
  end
end
