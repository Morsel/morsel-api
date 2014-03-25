# ## Schema Information
#
# Table name: `feed_items`
#
# ### Columns
#
# Name                | Type               | Attributes
# ------------------- | ------------------ | ---------------------------
# **`id`**            | `integer`          | `not null, primary key`
# **`subject_id`**    | `integer`          |
# **`subject_type`**  | `string(255)`      |
# **`deleted_at`**    | `datetime`         |
# **`visible`**       | `boolean`          | `default(FALSE)`
# **`created_at`**    | `datetime`         |
# **`updated_at`**    | `datetime`         |
#

require 'spec_helper'

describe FeedItem do
  subject(:feed_item) { FactoryGirl.build(:post_feed_item) }

  it { should respond_to(:subject) }
  it { should respond_to(:visible) }

  its(:visible) { should be_false }
end
