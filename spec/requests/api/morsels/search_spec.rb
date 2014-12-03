require_relative '_spec_helper'

describe 'GET /morsels/search morsels#search' do
  let(:endpoint) { '/morsels/search' }

  it_behaves_like 'PagePaginateable' do
    let(:paginateable_object_class) { Morsel }
    let(:additional_params) {{ morsel: { query: 'test' }}}

    before do
      paginateable_object_class.delete_all
      10.times do
        FactoryGirl.create(:morsel_with_creator, title: 'I have the word test in me!')
      end
      10.times do
        FactoryGirl.create(:morsel_with_creator, summary: 'I summarize that the word test is in me!')
      end
      10.times do
        FactoryGirl.create(:item_with_creator_and_morsel, description: 'I describe how the word test is in me!')
      end
    end
  end
end
