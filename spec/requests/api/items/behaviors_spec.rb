require_relative '_spec_helper'

describe 'Items Behaviors' do
  it_behaves_like 'CommentableController' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:commentable_route) { '/items' }
    let(:commentable) { FactoryGirl.create(:item_with_creator) }
  end

  it_behaves_like 'LikeableController' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:likeable_route) { '/items' }
    let(:likeable) { FactoryGirl.create(:item_with_creator) }
  end

  it_behaves_like 'ReportableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:reportable_route) { '/items' }
    let(:reportable) { FactoryGirl.create(:item_with_creator_and_morsel) }
  end
end
