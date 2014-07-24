require_relative '_spec_helper'

describe 'Places Behaviors' do
  it_behaves_like 'FollowableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:followable_route) { '/places' }
    let(:followable) { FactoryGirl.create(:existing_place) }
  end
end
