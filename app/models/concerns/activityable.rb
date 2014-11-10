module Activityable
  extend ActiveSupport::Concern

  included do
    has_one :activity, as: :action, dependent: :destroy

    class_attribute :activity_hidden
    class_attribute :activity_notification
    attr_accessor :silent

    after_commit :create_activity_for_activityable, on: :create
    def self.activity_hidden; false end
    def self.activity_notification; false end
    def activity_subject; raise 'NotImplementedError - activity_subject is not implemented for this Activityable' end
    def activity_creator; user end
    def additional_recipient_ids; nil end
  end

  private

  def create_activity_for_activityable
    ActivityWorker.perform_async(
      subject: {
        id: activity_subject.id,
        type: activity_subject.class.to_s
      },
      action: {
        id: id,
        type: self.class.to_s
      },
      creator_id: activity_creator.id,
      primary_recipient_id: recipient_id,
      additional_recipient_ids: additional_recipient_ids,
      notify_recipients: activity_notification,
      hidden: activity_hidden,
      silent: silent
    )
  end

  def recipient_id
    return nil if activity_subject.is_a?(Place)
    if self.is_a? MorselUserTag
      user_id
    elsif activity_subject.respond_to?(:creator)
      activity_subject.creator.id
    elsif activity_subject.is_a?(User)
      activity_subject.id
    end
  end
end
