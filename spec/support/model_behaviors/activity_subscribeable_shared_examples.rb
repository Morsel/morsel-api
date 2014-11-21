shared_examples 'ActivitySubscribeable' do
  context :saved do
    it 'should subscribe the subject creator to the subject' do
      expect(subject.activity_subscribers.count).to eq(1)
      expect(subject.activity_subscribers.first).to eq(subject.creator)
      expect(subject.activity_subscriptions.map(&:action) - subject.class.activity_subscription_actions).to be_empty
    end
  end

  context :destroyed do
    before { subject.destroy }

    it 'should unsubscribe the subject creator from the subject' do
      expect(subject.activity_subscribers.count).to be_zero
      expect(subject.activity_subscriptions.map(&:action)).to be_empty
    end
  end
end
