# ## Schema Information
#
# Table name: `morsels`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`like_count`**          | `integer`          | `default(0), not null`
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
#

require 'spec_helper'

describe Morsel do
  before do
    @morsel = FactoryGirl.build(:morsel)
  end

  subject { @morsel }

  it { should respond_to(:description) }
  it { should respond_to(:photo) }

  it { should be_valid }

  describe 'description and photo are missing' do
    before do
      @morsel.description = nil
      @morsel.photo = nil
    end
    it { should_not be_valid }
  end
end
