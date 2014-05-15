module Activityable
  extend ActiveSupport::Concern

  included do
    has_one :activity, as: :action, dependent: :destroy

    class_attribute :activity_notification
    after_create :create_activity
    def self.activity_notification; false end
    def subject; raise 'NotImplementedError - subject is not implemented for this Activityable' end
  end

  private

  def create_activity
    ActivityWorker.perform_async(subject.id, subject.class.to_s, id, self.class.to_s, user.id, recipient_id, activity_notification)
  end

  def recipient_id
    if subject.respond_to?(:creator)
      subject.creator.id
    elsif subject.kind_of?(User)
      subject.id
    end
  end
end
