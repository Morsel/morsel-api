require_relative '_spec_helper'

describe 'PUT /morsels/{:morsel_id} morsels#update' do
  let(:endpoint) { "/morsels/#{existing_morsel.id}" }
  let(:current_user) { FactoryGirl.create(:chef) }
  let(:existing_morsel) { FactoryGirl.create(:morsel_with_items, creator: current_user) }
  let(:new_title) { 'Shy Ronnie 2: Ronnie & Clyde' }

  it 'updates the Morsel' do
    put_endpoint  morsel: {
                    title: new_title
                  }

    expect_success
    expect_json_data_eq({
      'id' => existing_morsel.id,
      'title' => new_title,
      'draft' => false
    })

    new_morsel = Morsel.find(existing_morsel.id)
    expect(new_morsel.title).to eq(new_title)
    expect(new_morsel.draft).to eq(false)
  end

  it 'should set the draft to false when draft=false is passed' do
    existing_morsel.update(draft:true)

    put_endpoint  morsel: {
                    title: new_title,
                    draft: false
                  }

    expect_success
    expect_json_data_eq('draft' => false)

    new_morsel = Morsel.find(existing_morsel.id)
    expect(new_morsel.draft).to eq(false)
  end

  context 'primary_item_id is included' do
    let(:some_item) { FactoryGirl.create(:item_with_creator, morsel: existing_morsel) }
    it 'updates the primary_item_id' do
      put_endpoint  morsel: {
                      title: new_title,
                      primary_item_id: some_item.id
                    }

      expect_success

      new_morsel = Morsel.find json_data['id']
      expect_json_data_eq({
        'id' => new_morsel.id,
        'title' => new_morsel.title,
        'creator_id' => new_morsel.creator_id,
        'primary_item_id' => some_item.id
      })
      expect(new_morsel.primary_item_id).to eq(some_item.id)
    end

    it 'should fail if primary_item_id is not one of the Morsel\'s Items' do
      put_endpoint  morsel: {
                      title: new_title,
                      primary_item_id: FactoryGirl.create(:item).id
                    }

      expect_failure
      expect(json_errors['primary_item'].first).to eq('does not belong to this Morsel')
    end
  end

  context 'current_user is NOT Morsel creator' do
    let(:endpoint) { "/morsels/#{FactoryGirl.create(:morsel_with_items).id}" }
    it 'should NOT be authorized' do
      put_endpoint  morsel: {
                    title: new_title
                  }

      expect_failure
    end
  end
end
