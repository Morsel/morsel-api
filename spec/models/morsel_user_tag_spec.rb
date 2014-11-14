# ## Schema Information
#
# Table name: `morsel_user_tags`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`morsel_id`**   | `integer`          |
# **`user_id`**     | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe MorselUserTag do
  subject(:morsel_user_tag) { FactoryGirl.build(:morsel_user_tag, morsel: FactoryGirl.create(:morsel_with_items)) }
  let(:morsel) { morsel_user_tag.morsel }
  let(:user) { morsel_user_tag.user }

  it_behaves_like 'Activityable'
  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'

  it { should respond_to(:morsel) }
  it { should respond_to(:user) }

  its(:morsel) { should eq(morsel) }
  its(:user) { should eq(user) }

  context :saved do
    before { Sidekiq::Testing.inline! { subject.save! }}

    it 'should subscribe the tagged user to the morsel\'s items' do
      expect(morsel.items.map(&:activity_subscriptions).map(&:count).uniq).to eq([2]) # one for the creator and another for tagged user
      morsel.items.each do |item|
        user_activity_subscriptions = item.activity_subscriptions.where(subscriber_id: user.id)
        expect(user_activity_subscriptions.count).to eq(1)
        expect(user_activity_subscriptions.map(&:action).uniq).to eq(['comment'])
      end
    end

    it 'should NOT subscribe the tagged user to the morsel' do
      expect(morsel.activity_subscriptions.count).to eq(1) # one for the creator
      expect(morsel.activity_subscriptions.first.user).to eq(morsel.creator)
    end
  end

  context :destroyed do
    before { Sidekiq::Testing.inline! { subject.save!; subject.destroy! }}

    it 'should unsubscribe the tagged user from the morsel\'s items' do
      expect(morsel.items.map(&:activity_subscriptions).map(&:count).uniq).to eq([1]) # one for the creator

      morsel.items.each do |item|
        user_activity_subscriptions = item.activity_subscriptions.where(subscriber_id: user.id)
        expect(user_activity_subscriptions.count).to be_zero
      end
    end
  end
end
