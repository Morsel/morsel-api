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

require 'spec_helper'

describe Device do
  subject(:device) { FactoryGirl.build(:device) }

  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'

  it { should respond_to(:user) }
  it { should respond_to(:notification_settings) }

  it { should be_valid }

  describe 'user' do
    context 'is not present' do
      before { device.user = nil }
      it { should_not be_valid }
    end
  end

  describe 'name' do
    context 'is not present' do
      before { device.name = '' }
      it { should_not be_valid }
    end
  end

  describe 'token' do
    context 'is not present' do
      before { device.token = '' }
      it { should_not be_valid }
    end
  end

  describe 'model' do
    context 'is not present' do
      before { device.model = '' }
      it { should_not be_valid }
    end
  end

  describe 'notification_settings defaults' do
    before { subject.save }
    [:notify_comments_on_my_morsel, :notify_likes_my_morsel, :notify_new_followers].each do |notification_setting|
      its("#{notification_setting}?") { should be_true }
    end
  end

  context 'user already has a device' do
    before { FactoryGirl.create(:device, user: device.user) }

    it { should be_valid }
  end
end
