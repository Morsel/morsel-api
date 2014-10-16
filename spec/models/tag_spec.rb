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
  subject(:user_cuisine_tag) { FactoryGirl.build(:user_cuisine_tag) }

  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:tagger) }
  it { should respond_to(:taggable) }


  context 'User Tag' do
    let(:user) { FactoryGirl.create(:user) }

    it "is only valid for 'Cuisines' and 'Specialties'" do
      valid_types = User.allowed_keyword_types
      invalid_types = Keyword::VALID_TYPES - valid_types

      valid_types.each do |type|
        tag = Tag.create(tagger: user, keyword: FactoryGirl.create(type.underscore.to_sym), taggable: FactoryGirl.create(:user))
        expect(tag.valid?).to be_true
      end

      invalid_types.each do |type|
        tag = Tag.create(tagger: user, keyword: FactoryGirl.create(type.underscore.to_sym), taggable: FactoryGirl.create(:user))
        expect(tag.valid?).to be_false
      end
    end
  end
end
