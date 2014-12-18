require 'spec_helper'

describe CollectMorsel do
  let(:user) { FactoryGirl.create(:user_with_collection) }
  let(:morsel) { FactoryGirl.create(:morsel) }
  let(:collection) { user.collections.first }
  let(:note) { Faker::Lorem.sentence(rand(2..10)) }

  before do
    collection.morsels << FactoryGirl.create(:morsel)
  end

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      user: user,
      morsel: morsel,
      collection: collection
    }}
  end

  it 'should add the morsel to the collection' do
    call_service ({
      user: user,
      morsel: morsel,
      collection: collection,
      note: note
    })

    expect_service_success
    expect(service_response).to_not eq(nil)
    expect(service_response.note).to eq(note)
    expect(service_response.sort_order).to eq(1)
  end
end
