shared_examples 'Activityable' do
  describe '#create_activity' do
    it 'creates an Activity' do
      expect {
        Sidekiq::Testing.inline! { subject.save }
      }.to change(Activity, :count).by(safe_additional_recipients_count + 1)
    end

    context 'Class.activity_notification is true' do
      it 'creates a Notification' do
        expected_count = subject.activity_notification ? 1 : 0

        expect {
          Sidekiq::Testing.inline! { subject.save }
        }.to change(Notification, :count).by(expected_count + safe_additional_recipients_count)
      end

      context 'creator is the receiver' do
        it 'should NOT create a Notification if the creator is the receiver' do
          unless subject.activity_subject.kind_of?(User)
            subject.activity_subject.creator = subject.user
            expect {
              Sidekiq::Testing.inline! { subject.save }
            }.to change(Notification, :count).by(safe_additional_recipients_count)
          end
        end
      end
    end
  end
end

def safe_additional_recipients_count
  respond_to?(:additional_recipients_count) ? additional_recipients_count.to_i : 0
end
