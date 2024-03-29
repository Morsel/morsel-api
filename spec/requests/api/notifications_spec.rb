require 'spec_helper'

describe 'Notifications API' do
  describe 'GET /notifications notifications#index' do
    let(:endpoint) { '/notifications' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:last_user) { FactoryGirl.create(:user) }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_creator, creator: current_user) }

    context 'current_user\'s Morsel is liked' do
      before do
        Sidekiq::Testing.inline! { some_morsel.likers << FactoryGirl.create(:user) }
        Sidekiq::Testing.inline! { some_morsel.likers << last_user }
      end

      it 'returns the Like Activity of that Morsel in current_user\'s recent notifications' do
        get_endpoint

        expect_success

        expect_first_json_data_eq({
          'message' => "#{last_user.full_name_with_username} liked '#{some_morsel.title}'".truncate(Settings.morsel.notification_length, separator: ' ', omission: '... '),
          'marked_read_at' => nil,
          'payload_type' => 'Activity',
          'payload' => {
            'action_type' => 'Like',
            'subject_type' => 'Morsel',
            'subject' => {
              'id' => some_morsel.id,
              'title' => some_morsel.title
            }
          }
        })
      end

      context 'Morsel is unliked' do
        before do
          Morsel.last.destroy
        end

        it 'should not notify for that action' do
          get_endpoint

          expect_success
          expect_json_data_count 0
        end
      end
    end

    it_behaves_like 'TimelinePaginateable' do
      let(:paginateable_object_class) { Notification }
      before do
        paginateable_object_class.delete_all
        30.times { FactoryGirl.create(:morsel_like_activity_notification, user: current_user) }
      end
    end
  end

  describe 'PUT /notifications/mark_read notifications#mark_read' do
    let(:endpoint) { '/notifications/mark_read' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:unread_notification_count) { rand(2..6) }
    let(:some_morsel) { FactoryGirl.create(:morsel_with_creator, creator: current_user) }

    before do
      10.times { FactoryGirl.create(:morsel_like_activity_notification, user: current_user) }
    end


    it 'marks all notifications before `max_id` as read' do
      put_endpoint max_id: Notification.last.id - unread_notification_count

      expect_success
      expect(Notification.unread_for_user_id(current_user.id).count).to eq(unread_notification_count)
    end
  end

  describe 'PUT /notifications/:id/mark_read notifications#mark_read' do
    let(:endpoint) { "/notifications/#{notification.id}/mark_read" }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:notification) { FactoryGirl.create(:morsel_like_activity_notification, user: current_user) }

    it 'marks the notification with the specified `id` as read' do
      put_endpoint

      expect_success
      notification.reload
      expect(notification.marked_read_at).to_not be_nil
    end
  end

  describe 'GET /notifications/unread_count notifications#unread_count' do
    let(:endpoint) { '/notifications/unread_count' }
    let(:current_user) { FactoryGirl.create(:user) }
    let(:unread_notification_count) { rand(2..6) }

    before do
      10.times { FactoryGirl.create(:morsel_like_activity_notification, user: current_user) }
      Notification.where("id <= #{Notification.last.id - unread_notification_count}").update_all(marked_read_at: DateTime.now)
    end

    it 'returns the number of unread notifications' do
      get_endpoint

      expect_success
      expect_json_data_eq('unread_count' => unread_notification_count)
    end
  end
end
