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

class Place < ActiveRecord::Base
  include Authority::Abilities, Followable, TimelinePaginateable
  acts_as_paranoid
  is_sluggable :name, slug_column: :slug

  belongs_to  :creator, class_name: 'User'
  has_many    :employments, inverse_of: :place
  has_many    :users, through: :employments

  self.authorizer_name = 'ProfessionalAuthorizer'

  concerning :Information do
    included do
      store_accessor  :information,
                      :credit_cards,
                      :dining_options,
                      :dining_style,
                      :dress_code,
                      :formatted_phone,
                      :menu_mobile_url,
                      :menu_url,
                      :outdoor_seating,
                      :parking,
                      :parking_details,
                      :price_tier,
                      :public_transit,
                      :reservations,
                      :reservations_url,
                      :website_url
    end
  end

  concerning :Foursquare do
    included do
      after_commit :import_foursquare_venue_data, on: :create
    end

    def recently_imported?
      last_imported_at && last_imported_at > 30.days.ago
    end

    private

    def import_foursquare_venue_data
      FoursquareImportWorker.perform_async(
        creator_id: creator_id,
        place: {
          id: id
        }
      )
    end
  end
end
