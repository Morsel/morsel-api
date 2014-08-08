require_relative '_spec_helper'

describe 'Users Behaviors' do
  it_behaves_like 'FollowableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:followable_route) { '/users' }
    let(:followable) { FactoryGirl.create(:user) }
  end

  it_behaves_like 'ReportableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:reportable_route) { '/users' }
    let(:reportable) { FactoryGirl.create(:user) }
  end

  it_behaves_like 'TaggableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:taggable_route) { '/users' }
    let(:taggable) { current_user }
    let(:keyword) { FactoryGirl.create(:cuisine) }
    let(:existing_tag) { FactoryGirl.create(:user_cuisine_tag, tagger: current_user) }
  end
end
