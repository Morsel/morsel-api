require 'spec_helper'

describe CollectMorsel do
  let(:service_class) { CollectMorsel }

  let(:user) { FactoryGirl.create(:user_with_collection) }
  let(:morsel) { FactoryGirl.create(:morsel) }
  let(:collection) { user.collections.first }

  it 'should add the morsel to the collection' do
    call_service ({
      user: user,
      morsel: morsel,
      collection: collection
    })

    expect_service_success
    expect(service_response).to_not eq(nil)
  end

  context 'no user specified' do
    it 'throws an error' do
      call_service ({
        morsel: morsel,
        collection: collection
      })

      expect_service_failure
      expect_service_error('user', 'can\'t be blank')
    end
  end
end
