require_relative '_spec_helper'

describe 'Morsels Behaviors' do
  it_behaves_like 'ReportableController' do
    let(:current_user) { FactoryGirl.create(:chef) }
    let(:reportable_route) { '/morsels' }
    let(:reportable) { FactoryGirl.create(:morsel) }
  end
end
