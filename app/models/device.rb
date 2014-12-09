# ## Schema Information
#
# Table name: `devices`
#
# ### Columns
#
# Name                         | Type               | Attributes
# ---------------------------- | ------------------ | ---------------------------
# **`id`**                     | `integer`          | `not null, primary key`
# **`user_id`**                | `integer`          |
# **`name`**                   | `string(255)`      |
# **`token`**                  | `string(255)`      |
# **`model`**                  | `string(255)`      |
# **`created_at`**             | `datetime`         |
# **`updated_at`**             | `datetime`         |
# **`deleted_at`**             | `datetime`         |
# **`notification_settings`**  | `hstore`           | `default({})`
#

class Device < ActiveRecord::Base
  include Authority::Abilities,
          TimelinePaginateable

  acts_as_paranoid

  belongs_to :user
  has_many :remote_notifications

  before_create :default_values

  validates :user, presence: true
  validates :name, presence: true
  validates :token, presence: true
  validates :model, presence: true

  concerning :NotificationSettings do
    included do
      def self.notification_setting_keys
        [:notify_item_comment, :notify_morsel_like, :notify_morsel_morsel_user_tag, :notify_user_follow, :notify_tagged_morsel_item_comment]
      end

      self.notification_setting_keys.each do |notification_setting_key|
        store_accessor :notification_settings, notification_setting_key
        self.class_eval do
          define_method :"#{notification_setting_key}?" do
            ActiveRecord::ConnectionAdapters::Column.value_to_boolean(send(notification_setting_key))
          end
        end
      end
    end

    private

    def default_notification_values
      Device.notification_setting_keys.each do |notification_setting_key|
        self.send("#{notification_setting_key}=", true) if self.send(notification_setting_key).nil?
      end
    end
  end

  private

  def default_values
    default_notification_values
  end
end
