shared_examples 'Activityable' do
  describe '#create_activity' do
    it 'creates an Activity' do
      expect {
        Sidekiq::Testing.inline! { subject.save }
      }.to change(Activity, :count).by(1)
    end

    context 'Class.activity_notification is true' do
      it 'creates a Notification' do
        expected_count = subject.activity_notification ? 1 : 0
        expect {
          Sidekiq::Testing.inline! { subject.save }
        }.to change(Notification, :count).by(expected_count)
      end

      context 'creator is the receiver' do
        it 'should NOT create a Notification if the creator is the receiver' do
          unless subject.activity_subject.kind_of?(User)
            subject.activity_subject.creator = subject.user
            expect {
              Sidekiq::Testing.inline! { subject.save }
            }.to change(Notification.where(user_id: subject.user.id), :count).by(0)
          end
        end
      end
    end
  end
end
