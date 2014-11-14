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
      notify_recipients: activity_notification,
      hidden: activity_hidden,
      silent: silent
    )
  end
end
