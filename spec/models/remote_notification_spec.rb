# ## Schema Information
#
# Table name: `remote_notifications`
#
# ### Columns
#
# Name                   | Type               | Attributes
# ---------------------- | ------------------ | ---------------------------
# **`id`**               | `integer`          | `not null, primary key`
# **`device_id`**        | `integer`          |
# **`notification_id`**  | `integer`          |
# **`user_id`**          | `integer`          |
# **`activity_type`**    | `string(255)`      |
# **`reason`**           | `string(255)`      |
# **`created_at`**       | `datetime`         |
# **`updated_at`**       | `datetime`         |
#

require 'spec_helper'

describe RemoteNotification do
  subject(:item_comment_remote_notification) { FactoryGirl.create(:item_comment_remote_notification) }

  it_behaves_like 'Timestamps'

  it { should respond_to(:device) }
  it { should respond_to(:user) }
  it { should respond_to(:notification) }

  it { should be_valid }

  its(:activity_type) { should eq('item_comment') }
  its(:reason) { should eq('created') }
  its(:user_id) { should eq(subject.notification.user_id) }
end
