# ## Schema Information
#
# Table name: `subscribers`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`email`**       | `string(255)`      |
# **`url`**         | `string(255)`      |
# **`source_url`**  | `string(255)`      |
# **`role`**        | `string(255)`      |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Subscriber do
  subject(:subscriber) { FactoryGirl.build(:subscriber) }

  it { should respond_to(:email) }
  it { should respond_to(:url) }
  it { should respond_to(:source_url) }
  it { should respond_to(:role) }

  it { should be_valid }

  describe 'email' do
    context 'already taken' do
      before do
        subscriber_with_same_email = subscriber.dup
        subscriber_with_same_email.save
      end

      it { should_not be_valid }
    end
  end
end
