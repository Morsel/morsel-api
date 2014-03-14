shared_examples 'Activityable' do
  describe '#create_activity' do
    it 'creates an Activity' do
      expect{
        Sidekiq::Testing.inline! { activityable_object.save }
      }.to change(Activity, :count).by(1)
    end

    it 'creates a Notification if Class.activity_notification is true' do
      expected_count = activityable_object.activity_notification ? 1 : 0
      if
        expect{
          Sidekiq::Testing.inline! { activityable_object.save }
        }.to change(Notification, :count).by(expected_count)
      end
    end
  end
end
