# ## Schema Information
#
# Table name: `places`
#
# ### Columns
#
# Name                         | Type               | Attributes
# ---------------------------- | ------------------ | ---------------------------
# **`id`**                     | `integer`          | `not null, primary key`
# **`name`**                   | `string(255)`      |
# **`slug`**                   | `string(255)`      |
# **`address`**                | `string(255)`      |
# **`city`**                   | `string(255)`      |
# **`state`**                  | `string(255)`      |
# **`postal_code`**            | `string(255)`      |
# **`country`**                | `string(255)`      |
# **`facebook_page_id`**       | `string(255)`      |
# **`twitter_username`**       | `string(255)`      |
# **`foursquare_venue_id`**    | `string(255)`      |
# **`foursquare_timeframes`**  | `json`             |
# **`information`**            | `hstore`           | `default({})`
# **`creator_id`**             | `integer`          |
# **`created_at`**             | `datetime`         |
# **`updated_at`**             | `datetime`         |
# **`deleted_at`**             | `datetime`         |
# **`last_imported_at`**       | `datetime`         |
# **`lat`**                    | `float`            |
# **`lon`**                    | `float`            |
# **`widget_url`**             | `string(255)`      |
#

require 'spec_helper'

describe Place do
  subject(:place) { FactoryGirl.build(:place) }

  it_behaves_like 'Paranoia'
  it_behaves_like 'Timestamps'

  it { should respond_to(:creator) }
  it { should respond_to(:name) }
  it { should respond_to(:address) }
  it { should respond_to(:city) }
  it { should respond_to(:state) }
  it { should respond_to(:postal_code) }
  it { should respond_to(:country) }
  it { should respond_to(:facebook_page_id) }
  it { should respond_to(:twitter_username) }
  it { should respond_to(:foursquare_venue_id) }
  it { should respond_to(:foursquare_timeframes) }
  it { should respond_to(:information) }

  context :saved do
    before { place.save }
    describe 'slug' do
      it 'generates one if it does not exist' do
        expect(place.slug).to_not be_nil
      end
    end
  end

  context :Foursquare do
    before { stub_foursquare_venue }
    it 'queues the FoursquareImportWorker after creation' do
        expect {
          place.save
        }.to change(FoursquareImportWorker.jobs, :size).by(1)
    end

    describe :recently_imported? do
      context 'within and including the past 30 days' do
        before { place.last_imported_at = 5.days.ago }
        it 'returns true' do
          expect(place.recently_imported?).to be_true
        end
      end
      context 'outside the last 31 days' do
        before { place.last_imported_at = 31.days.ago }
        it 'returns false' do
          expect(place.recently_imported?).to be_false
        end
      end
    end
  end

  context :widget do
    subject(:place_with_widget) { FactoryGirl.build(:place_with_widget) }
    its(:widget_url) { should_not be_nil }
  end
end
