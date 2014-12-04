require 'spec_helper'

describe CreateActivity do
  let(:service_params) { base_params }
  let(:base_params) {{
    subject: {
      id: item.id,
      type: 'Item'
    },
    action: {
      id: comment.id,
      type: 'Comment'
    },
    creator_id: comment.commenter_id
  }}
  let(:item) { morsel.items.first }
  let(:morsel) { Sidekiq::Testing.inline! { FactoryGirl.create(:morsel_with_creator_and_tagged_users, tagged_users_count: tagged_users_count) }}
  let(:morsel_user_tag) { morsel.morsel_user_tags.first }
  let(:tagged_users_count) { rand(2..5) }
  let(:comment) { Sidekiq::Testing.inline! { FactoryGirl.create(:item_comment, commentable: item) }}

  before do
    comment.activity.destroy! # destroy the comment's activity since we're testing creating activity
    ActivitySubscription.update_all active: true
  end

  it 'should create an activity' do
    expect{
      call_service service_params
    }.to change(Activity.where(action:comment), :count).by(1)

    expect_service_success
    expect(service_response).to eq(Activity.last)
    expect(service_response.action).to eq(comment)
    expect(Activity.where(action:service_response.action).count).to eq(1)
  end

  it 'should NOT create notifications by default' do
    expect{
      call_service service_params
    }.to change(Notification, :count).by(0)
  end


  context 'notify_recipients=true' do
    let(:service_params) { base_params.merge({ notify_recipients: true }) }

    context 'has subscribers' do
      it 'should create notifications for each subscriber' do
        expect{
          call_service service_params
        }.to change(Notification, :count).by(tagged_users_count + 1)
      end

      context 'tagged user leaves a comment' do
        let(:tagged_user_who_commented) { morsel_user_tag.user }
        before do
          Sidekiq::Testing.inline! { FactoryGirl.create(:item_comment, commentable: item, commenter: tagged_user_who_commented) }
        end

        it 'should give the tagged user an additional activity subscription' do
          expect(tagged_user_who_commented.activity_subscriptions.where(subject_id: item.id).count).to eq(2)
          expect(tagged_user_who_commented.activity_subscriptions.where(subject_id: item.id).map(&:reason).sort).to eq(['commented', 'tagged'])
        end

        it 'should create only one notification for the subscriber' do
          expect{
            call_service service_params
          }.to change(Notification.where(user_id: tagged_user_who_commented), :count).by(1)
        end
      end
    end
  end
end
