require 'spec_helper'

describe SubscribeToSubjectActivity do
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

  it 'should subscribe the subscriber to the morsel activity actions specified' do
    expect {
      call_service ({
        subject: subject,
        subscriber: subscriber,
        actions: actions,
        reason: reason,
        active: true
      })
    }.to change(subject.activity_subscribers, :count).by(1)

    expect_service_success
    expect_service_response_count actions.count
    expect(actions).to eq(service_response.map(&:action))
    expect(service_response.map(&:active).uniq).to eq([true])
    expect(service_response.map(&:reason).uniq).to eq([reason])
    expect(subject.activity_subscribers).to eq([subscriber])
    expect(subject.activity_subscriptions.count).to eq(actions.count)
  end

  context 'subscription already exists' do
    before do
      # Create the first action
      ActivitySubscription.create(
        subject: subject,
        subscriber: subscriber,
        action: actions.first,
        reason: reason,
        active: true
      )
    end

    it 'should still create a new subscription' do
      expect {
        call_service ({
          subject: subject,
          subscriber: subscriber,
          actions: actions,
          reason: reason,
          active: true
        })
      }.to change(subject.activity_subscribers, :count).by(0)

      expect_service_success
      expect_service_response_count (actions.count)
      expect(actions).to eq(service_response.map(&:action))
      expect(service_response.map(&:active).uniq).to eq([true])
      expect(service_response.map(&:reason).uniq).to eq([reason])
      expect(subject.activity_subscribers).to eq([subscriber])
      expect(subject.activity_subscriptions.count).to eq(actions.count + 1)
    end
  end

  describe 'active' do
    context 'not passed' do
      it 'should default to active=true' do
        call_service ({
          subject: subject,
          subscriber: subscriber,
          actions: actions,
          reason: reason
        })

        expect_service_success
        expect(service_response.map(&:active).uniq).to eq([true])
      end
    end

    context 'active=true passed' do
      it 'should set activity activity_subscriptions to active=true' do
        call_service ({
          subject: subject,
          subscriber: subscriber,
          actions: actions,
          reason: reason,
          active: true
        })

        expect_service_success
        expect(service_response.map(&:active).uniq).to eq([true])
      end
    end

    context 'active=false passed' do
      it 'should set activity activity_subscriptions to active=false' do
        call_service ({
          subject: subject,
          subscriber: subscriber,
          actions: actions,
          reason: reason,
          active: false
        })

        expect_service_success
        expect(service_response.map(&:active).uniq).to eq([false])
      end
    end
  end
end
