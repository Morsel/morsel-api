require_relative '_spec_helper'

describe 'POST /morsels morsels#create', sidekiq: :inline do
  let(:endpoint) { '/morsels' }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:expected_title) { 'Bake Sale!' }

  context 'non-chef' do
    let(:current_user) { FactoryGirl.create(:user) }
    it 'creates a Morsel' do
      post_endpoint morsel: {
                      title: expected_title
                    }

      expect_success

      new_morsel = Morsel.find json_data['id']
      expect_json_data_eq({
        'id' => new_morsel.id,
        'title' => new_morsel.title,
        'creator_id' => new_morsel.creator_id,
        'title' => expected_title,
      })

      expect(json_data['photos']).to be_nil
      expect(new_morsel.draft).to be_true
    end
  end

  it 'creates a Morsel' do
    post_endpoint morsel: {
                    title: expected_title
                  }

    expect_success

    new_morsel = Morsel.find json_data['id']
    expect_json_data_eq({
      'id' => new_morsel.id,
      'title' => new_morsel.title,
      'creator_id' => new_morsel.creator_id,
      'title' => expected_title,
    })

    expect(json_data['photos']).to be_nil
    expect(new_morsel.draft).to be_true
  end

  context 'place_id is passed' do
    let(:place) { FactoryGirl.create(:place) }

    it 'associates that Morsel with that Place' do
      post_endpoint morsel: {
                      title: expected_title,
                      place_id: place.id
                    }

      expect_success

      new_morsel = Morsel.find json_data['id']
      expect_json_data_eq({
        'id' => new_morsel.id,
        'title' => new_morsel.title,
        'creator_id' => new_morsel.creator_id,
        'title' => expected_title,
        'place_id' => place.id
      })

      expect(json_data['photos']).to be_nil
      expect(new_morsel.draft).to be_true
    end
  end

  context 'draft is set to false' do
    it 'creates a draft Morsel' do
      post_endpoint morsel: {
                      title: expected_title,
                      draft: false
                    }

      expect_success

      new_morsel = Morsel.find json_data['id']
      expect_json_data_eq({
        'id' => new_morsel.id,
        'title' => new_morsel.title,
        'creator_id' => new_morsel.creator_id,
        'title' => expected_title,
      })

      expect(new_morsel.draft).to be_false
    end
  end

  context 'primary_item_id is included' do
    let(:some_item) { FactoryGirl.create(:item_with_creator) }
    it 'should fail since a new Morsel has no Items' do
      post_endpoint morsel: {
                      title: expected_title,
                      primary_item_id: FactoryGirl.create(:item).id
                    }

      expect(response).to_not be_success
      expect(json_errors['primary_item'].first).to eq('does not belong to this Morsel')
    end
  end
end
