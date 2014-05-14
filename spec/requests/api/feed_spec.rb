require 'spec_helper'

describe 'Feed API' do
  describe 'GET /feed' do
    let(:endpoint) { '/feed' }
    let(:morsels_count) { 3 }

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { FeedItem }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:visible_morsel_feed_item) }
      end
    end

    before { morsels_count.times { Sidekiq::Testing.inline! { FactoryGirl.create(:morsel_with_items) } }}

    it 'returns the Feed' do
      get_endpoint

      expect_success
      expect_json_data_count morsels_count

      last_morsel = Morsel.last
      expect_first_json_data_eq({
        'subject_type' => 'Morsel',
        'subject' => {
          'id' => last_morsel.id,
          'title' => last_morsel.title,
          'draft' => last_morsel.draft
        }
      })
    end

    context 'Morsel is deleted' do
      before { Morsel.last.destroy }

      it 'removes the Feed Item' do
        get_endpoint

        expect_success
        expect_json_data_count(morsels_count - 1)
      end
    end

    context 'Morsel is marked as draft' do
      before { Morsel.last.update(draft: true) }

      it 'omits the Feed Item' do
        get_endpoint

        expect_success
        expect_json_data_count(morsels_count - 1)
      end
    end
  end
end
