module Activityable
  extend ActiveSupport::Concern

  included do
    has_one :activity, as: :action, dependent: :destroy

    class_attribute :activity_notification
    after_commit :create_activity, on: :create
    def self.activity_notification; false end
    def subject; raise 'NotImplementedError - subject is not implemented for this Activityable' end
  end

  private

  def create_activity
    ActivityWorker.perform_async(
      subject: {
        id: subject.id,
        type: subject.class.to_s
      },
      action: {
        id: id,
        type: self.class.to_s
      },
      creator_id: user.id,
      recipient_id: recipient_id,
      notify_recipient: activity_notification
    )
  end

  def recipient_id
    return nil if subject.kind_of?(Place)
    if subject.respond_to?(:creator)
      subject.creator.id
    elsif subject.kind_of?(User)
      subject.id
    end
  end
end
