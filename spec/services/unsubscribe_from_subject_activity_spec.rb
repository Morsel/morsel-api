require 'spec_helper'

describe UnsubscribeFromSubjectActivity do
  let(:service_class) { described_class }

  let(:subscriber) { FactoryGirl.create(:user) }
  let(:subject) { FactoryGirl.create(:morsel) }
  let(:actions) { ActivitySubscription.actions.keys.drop(1).sample(rand(2..3)) }
  let(:reason) { ActivitySubscription.reasons.keys.drop(1).sample }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      subject: subject,
      subscriber: subscriber,
      actions: actions,
      reason: reason
    }}
  end

  context 'subscription exists' do
    before do
      actions.each do |action|
        ActivitySubscription.create(
          subject: subject,
          subscriber: subscriber,
          action: action,
          reason: reason
        )
      end
    end

    it 'should unsubscribe the subscriber from the morsel activity actions specified' do
      expect {
        call_service ({
          subject: subject,
          subscriber: subscriber,
          actions: actions,
          reason: reason
        })
      }.to change(subject.activity_subscribers, :count).by(-1)

      expect_service_success
      expect(service_response.uniq).to eq([true])
    end
  end

  context 'subscription does NOT exist' do
    it 'should not crap out' do
      call_service ({
        subject: subject,
        subscriber: subscriber,
        actions: actions,
        reason: reason
      })

      expect_service_success
      expect(service_response.uniq).to eq([false])

      expect(subject.activity_subscribers).to be_empty
      expect(subject.activity_subscriptions.count).to be_zero
    end
  end
end
