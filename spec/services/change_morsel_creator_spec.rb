require 'spec_helper'

describe ChangeMorselCreator do
  let(:morsel) { FactoryGirl.create(:morsel, creator: creator) }
  let(:creator) { FactoryGirl.create(:user) }
  let(:new_creator) { FactoryGirl.create(:user) }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      morsel: morsel,
      new_creator: new_creator
    }}
  end

  it 'should change the morsel\'s creator to the new creator' do
    call_service ({
      morsel: morsel,
      new_creator: new_creator
    })

    expect_service_success

    expect(service_response).to eq(morsel)
    expect(service_response.creator).to eq(new_creator)
    expect(new_creator.has_role?(:creator, morsel)).to be_true
    expect(morsel.roles).to eq(morsel.roles)
    expect(morsel.url).to eq("#{Settings.morsel.web_url}/#{new_creator.username}/#{morsel.id}-#{morsel.cached_slug}")
  end

  context 'morsel has no existing creator' do
    before { morsel.creator = nil }

    it 'throws an error' do
      call_service ({
        morsel: morsel,
        new_creator: new_creator
      })

      expect_service_failure
      expect_service_error('morsel', 'has no existing creator')
    end
  end
end
