# ## Schema Information
#
# Table name: `collections`
#
# ### Columns
#
# Name               | Type               | Attributes
# ------------------ | ------------------ | ---------------------------
# **`id`**           | `integer`          | `not null, primary key`
# **`title`**        | `string(255)`      |
# **`description`**  | `text`             |
# **`user_id`**      | `integer`          |
# **`place_id`**     | `integer`          |
# **`deleted_at`**   | `datetime`         |
# **`created_at`**   | `datetime`         |
# **`updated_at`**   | `datetime`         |
# **`cached_slug`**  | `string(255)`      |
#

require 'spec_helper'

describe Collection do
  subject(:collection) { FactoryGirl.build(:collection) }

  it_behaves_like 'Paranoia'
  it_behaves_like 'Sluggable'
  it_behaves_like 'Timestamps'
  it_behaves_like 'UserCreatable' do
    let(:user) { subject.user }
  end

  it { should respond_to(:title) }
  it { should respond_to(:description) }

  it { should respond_to(:user) }
  it { should respond_to(:place) }

  it { should be_valid }

  its(:morsels) { should be_empty }

  describe 'title' do
    context 'greater than 70 characters' do
      before do
        subject.title = Faker::Lorem.characters(71)
      end

      it { should_not be_valid }
    end
  end

  context :saved do
    before { subject.save }

    its(:cached_slug) { should_not be_nil }

    it 'updates the url' do
      expect(collection.url).to eq("https://test.eatmorsel.com/#{collection.user.username}/#{collection.id}-#{collection.cached_slug}")
    end

    context 'title changes' do
      let(:new_title) { 'Some New Title!' }
      before do
        @old_slug = subject.cached_slug
        subject.title = new_title
        subject.save
      end

      it 'should update the slug' do
        expect(subject.cached_slug.to_s).to eq('some-new-title')
      end
    end
  end

  context 'has morsels' do
    subject(:collection_with_morsels) { FactoryGirl.create(:collection_with_morsels) }

    its(:morsels) { should_not be_empty }

    describe 'Collection gets destroyed' do
      it 'should NOT destroy its Morsels' do
        subject.destroy
        subject.morsels.each do |morsel|
          expect(morsel.destroyed?).to be_false
        end
      end
    end
  end
end
