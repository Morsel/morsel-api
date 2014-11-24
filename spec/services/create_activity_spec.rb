require 'spec_helper'

describe CreateActivity do
  subject(:service) { call_service service_params }
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
  let(:activity_count) { Activity.count }

  before do
    comment.activity.destroy # destroy the comment's activity since we're testing creating activity
    activity_count
    ActivitySubscription.update_all active:true
    service
  end

  it { should be_valid }
  its(:response) { should eq(Activity.last) }

  it 'should create an activity' do
    expect(Activity.last.action).to eq(comment)
  end

  context 'notify_recipients=true' do
    let(:service_params) { base_params.merge({ notify_recipients: true }) }

    context 'has subscribers' do
      it 'should create notifications for each subscriber' do
        expect(Notification.all.map(&:user_id).sort).to eq([morsel.creator_id] + morsel.tagged_user_ids)
      end
    end
  end
end
