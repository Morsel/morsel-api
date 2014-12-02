require_relative '_spec_helper'

describe 'GET /hashtags/search keywords#search' do
  let(:endpoint) { '/hashtags/search' }

  context 'promoted' do
    let(:promoted_keywords_count) { rand(2..6) }
    before do
      promoted_keywords_count.times { FactoryGirl.create(:hashtag, promoted: true) }
      rand(1..3).times { FactoryGirl.create(:hashtag) }
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Keyword }
      let(:additional_params) {{ keyword: { promoted: true }}}

      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:hashtag, promoted: true) }
      end
    end
  end
end
