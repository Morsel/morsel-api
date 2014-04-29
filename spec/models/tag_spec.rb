# ## Schema Information
#
# Table name: `tags`
#
# ### Columns
#
# Name                 | Type               | Attributes
# -------------------- | ------------------ | ---------------------------
# **`id`**             | `integer`          | `not null, primary key`
# **`tagger_id`**      | `integer`          |
# **`keyword_id`**     | `integer`          |
# **`taggable_id`**    | `integer`          |
# **`taggable_type`**  | `string(255)`      |
# **`deleted_at`**     | `datetime`         |
# **`created_at`**     | `datetime`         |
# **`updated_at`**     | `datetime`         |
#

require 'spec_helper'

describe Tag do
  subject(:user_tag) { FactoryGirl.build(:user_tag) }

  it { should respond_to(:tagger) }
  it { should respond_to(:taggable) }

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:user_tag) }
    let(:user) { user_creatable_object.user }
  end
end
