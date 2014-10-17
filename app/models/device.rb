# ## Schema Information
#
# Table name: `devices`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`name`**        | `string(255)`      |
# **`token`**       | `string(255)`      |
# **`model`**       | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
# **`deleted_at`**  | `datetime`         |
#

class Device < ActiveRecord::Base
  include Authority::Abilities, TimelinePaginateable
  acts_as_paranoid

  belongs_to :user

  before_create :default_values

  validates :user, presence: true
  validates :name, presence: true
  validates :token, presence: true
  validates :model, presence: true

  concerning :NotificationSettings do
    NOTIFICATION_SETTINGS = [:notify_comments_on_my_morsel, :notify_likes_my_morsel, :notify_new_followers]
    included do
      NOTIFICATION_SETTINGS.each do |notification_setting|
        store_accessor :notification_settings, notification_setting
        self.class_eval do
          define_method :"#{notification_setting}?" do
            ActiveRecord::ConnectionAdapters::Column.value_to_boolean(send(notification_setting))
          end
        end
      end
    end

    private

    def default_notification_values
      NOTIFICATION_SETTINGS.each do |notification_setting|
        self.send("#{notification_setting}=", true) if self.send(notification_setting).nil?
      end
    end
  end

  private

  def default_values
    default_notification_values
  end
end
