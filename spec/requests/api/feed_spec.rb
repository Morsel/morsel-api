require 'spec_helper'

describe 'Feed API' do
  describe 'GET /feed' do
    let(:endpoint) { '/feed' }
    let(:morsels_count) { rand(2..6) }

    before do
      morsels_count.times { FactoryGirl.create(:morsel_with_items) }
    end

    context 'public' do
      it 'returns nothing if no `featured` Feed Items exist' do
        get_endpoint

        expect_success
        expect_json_data_count 0
      end

      context '`featured` Feed Items exist' do
        let(:featured_feed_items_count) { rand(2..6) }

        it_behaves_like 'TimelinePaginateable' do
          let(:paginateable_object_class) { FeedItem }
          before do
            paginateable_object_class.delete_all
            30.times { FactoryGirl.create(:morsel_with_items, featured_feed_item: true) }
          end
        end

        before { featured_feed_items_count.times { FactoryGirl.create(:morsel_with_items, featured_feed_item: true) }}

        it 'returns any `featured` Feed Items' do
          get_endpoint

          expect_success
          expect_json_data_count featured_feed_items_count
        end

        context 'Morsel is deleted' do
          before { Morsel.last.destroy }

          it 'removes the Feed Item' do
            get_endpoint

            expect_success
            expect_json_data_count(featured_feed_items_count - 1)
          end
        end

        context 'Morsel is marked as draft' do
          before { Morsel.last.update(draft: true) }

          it 'omits the Feed Item' do
            get_endpoint

            expect_success
            expect_json_data_count(featured_feed_items_count - 1)
          end
        end
      end
    end

    context 'authenticated' do
      let(:current_user) { FactoryGirl.create(:user) }

      context 'following Users' do
        let(:morsels_from_followed_users) { rand(2..6) }

        it_behaves_like 'TimelinePaginateable' do
          let(:paginateable_object_class) { FeedItem }
          before do
            paginateable_object_class.delete_all
            30.times do
              morsel = FactoryGirl.create(:morsel_with_items)
              morsel.user.followers << current_user
            end
          end
        end

        before do
          morsels_from_followed_users.times do
            morsel = FactoryGirl.create(:morsel_with_items)
            morsel.user.followers << current_user
          end
        end

        it 'returns any Feed Items from current_user\'s Followed Users' do
          get_endpoint

          expect_success
          expect_json_data_count morsels_from_followed_users
        end

        context 'Morsel is marked as draft' do
          before { Morsel.last.update(draft: true) }

          it 'omits the Feed Item' do
            get_endpoint

            expect_success
            expect_json_data_count(morsels_from_followed_users - 1)
          end
        end

        context 'current_user Feed Item exists' do
          let(:current_user_morsel_count) { rand(2..6) }
          before { current_user_morsel_count.times { FactoryGirl.create(:morsel_with_items, creator: current_user) }}

          it 'returns any Feed Items from current_user\'s Followed Users in addition to the current_user\'s' do
            get_endpoint

            expect_success
            expect_json_data_count(morsels_from_followed_users + current_user_morsel_count)
          end
        end
      end
    end
  end
end
