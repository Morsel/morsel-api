# ## Schema Information
#
# Table name: `items`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `integer`          | `not null, primary key`
# **`description`**         | `text`             |
# **`created_at`**          | `datetime`         |
# **`updated_at`**          | `datetime`         |
# **`creator_id`**          | `integer`          |
# **`photo`**               | `string(255)`      |
# **`photo_content_type`**  | `string(255)`      |
# **`photo_file_size`**     | `string(255)`      |
# **`photo_updated_at`**    | `datetime`         |
# **`deleted_at`**          | `datetime`         |
# **`nonce`**               | `string(255)`      |
# **`photo_processing`**    | `boolean`          |
# **`morsel_id`**           | `integer`          |
# **`sort_order`**          | `integer`          |
# **`template_order`**      | `integer`          |
# **`comments_count`**      | `integer`          | `default(0), not null`
#

require 'spec_helper'

describe Item do
  subject(:item) { FactoryGirl.build(:item) }

  it_behaves_like 'Commentable'
  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    subject(:user_creatable_object) { FactoryGirl.build(:item_with_creator) }
    let(:user) { subject.creator }
  end

  it { should respond_to(:description) }
  it { should respond_to(:photo) }
  it { should respond_to(:nonce) }
  it { should respond_to(:sort_order) }
  it { should respond_to(:template_order) }

  it { should respond_to(:creator) }
  it { should respond_to(:morsel) }

  it { should be_valid }

  context 'saved with creator' do
    subject(:item) { FactoryGirl.create(:item_with_creator) }

    it 'adds :creator Role to the creator' do
      expect(item.creator.has_role?(:creator, item)).to be_true
      expect(item.creator.can_update?(item)).to be_true
    end

    describe 'activities' do
      before do
        Sidekiq::Testing.inline! { item.comments << FactoryGirl.create(:item_comment) }
      end
      context 'deleting a Item' do
        before do
          item.destroy
        end
        it 'should delete the Activities' do
          expect(item.activities).to be_empty
        end
      end
    end
  end

  context 'morsel is missing' do
    before { item.morsel = nil }
    it { should_not be_valid }
  end

  describe 'changing the sort_order in a morsel' do
    subject(:morsel_with_items) { FactoryGirl.create(:morsel_with_items, items_count: 3) }
    subject(:first_item) { morsel_with_items.items.first }
    before do
      first_item.update(sort_order: 2)
    end

    it 'increments the sort_order for all items after new sort_order' do
      expect(morsel_with_items.items.last.sort_order).to eq(morsel_with_items.items.count + 1)
    end

    it 'sets the new sort_order' do
      expect(first_item.sort_order).to eq(2)
    end
  end

  describe 'getting the the sort_order in a morsel' do
    subject(:morsel_with_items) { FactoryGirl.create(:morsel_with_items) }
    subject(:first_item) { morsel_with_items.items.first }

    it 'returns the sort_order' do
      expect(first_item.sort_order).to eq(1)
    end
  end

  describe '#url' do
    let(:morsel_with_items) { FactoryGirl.create(:morsel_with_items) }
    let(:first_item) { morsel_with_items.items.first }
    subject(:url) { first_item.url }

    it { should eq("https://test.eatmorsel.com/#{first_item.creator.username}/#{morsel_with_items.id}-#{morsel_with_items.cached_slug}/1") }
  end
end
