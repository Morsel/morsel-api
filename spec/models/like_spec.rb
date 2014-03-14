# ## Schema Information
#
# Table name: `likes`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`user_id`**     | `integer`          |
# **`morsel_id`**   | `integer`          |
# **`deleted_at`**  | `datetime`         |
# **`created_at`**  | `datetime`         |
# **`updated_at`**  | `datetime`         |
#

require 'spec_helper'

describe Like do
  subject(:like) { FactoryGirl.build(:like) }

  it { should respond_to(:user) }
  it { should respond_to(:morsel) }

  it_behaves_like 'Activityable' do
    let(:activityable_object) { like }
  end
end
