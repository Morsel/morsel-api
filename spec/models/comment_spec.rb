# ## Schema Information
#
# Table name: `comments`
#
# ### Columns
#
# Name                    | Type               | Attributes
# ----------------------- | ------------------ | ---------------------------
# **`id`**                | `integer`          | `not null, primary key`
# **`commenter_id`**      | `integer`          |
# **`commentable_id`**    | `integer`          |
# **`description`**       | `text`             |
# **`deleted_at`**        | `datetime`         |
# **`created_at`**        | `datetime`         |
# **`updated_at`**        | `datetime`         |
# **`commentable_type`**  | `string(255)`      |
#

require 'spec_helper'

describe Comment do
  subject(:item_comment) { FactoryGirl.build(:item_comment, commentable: item) }
  let(:item) { Sidekiq::Testing.inline! { FactoryGirl.create(:item_with_creator_and_morsel) }}
  let(:commenter) { item_comment.commenter }

  it_behaves_like 'Activityable'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:commenter) }
  it { should respond_to(:commentable) }
  it { should respond_to(:description) }

  its(:commenter) { should eq(commenter) }
  its(:commentable) { should eq(item) }

  context :saved do
    before { Sidekiq::Testing.inline! { subject.save! }}

    it 'should subscribe the commenter to the item' do
      expect(item.activity_subscriptions.count).to eq(2) # one for the creator and another for commenter
      commenter_activity_subscriptions = item.activity_subscriptions.where(subscriber_id: commenter.id)
      expect(commenter_activity_subscriptions.count).to eq(1)
      expect(commenter_activity_subscriptions.map(&:action).uniq).to eq(['comment'])
    end

    it 'should NOT subscribe the tagged user to the morsel' do
      expect(item.morsel.activity_subscriptions.count).to eq(1) # one for the creator
      expect(item.morsel.activity_subscriptions.first.user).to eq(item.morsel.creator)
    end
  end

  context :destroyed do
    before { Sidekiq::Testing.inline! { subject.save!; subject.destroy! }}

    context 'commenter has other comments on commentable' do
      it 'should NOT unsubscribe commenter from commentable'
    end

    context 'commenter has NO other comments on commentable' do
      it 'should unsubscribe commenter from commentable'
    end

    it 'should unsubscribe the commenter from the item if commenter has no other comments in commentable' do
      expect(item.activity_subscriptions.count).to eq(1) # one for the creator
      expect(item.activity_subscriptions.where(subscriber_id: commenter.id).count).to be_zero
    end
  end
end
