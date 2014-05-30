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
#

FactoryGirl.define do
  factory :place do
    association(:creator, factory: :user)

    name { Faker::Company.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.zip_code }
    country { Faker::Address.country }
    foursquare_venue_id { Faker::Lorem.characters(10) }
    foursquare_timeframes {
      [
        {
          days: "Mon-Fri",
          includesToday: true,
          open: [
            {
              renderedTime: "11:00 AM-9:00 PM"
            }
          ],
          segments: []
        },
        {
          days: "Sat",
          open: [
            {
              renderedTime: "9:00 AM-10:00 PM"
            }
          ],
          segments: []
        },
        {
          days: "Sun",
          open: [
            {
              renderedTime: "9:00 AM-9:00 PM"
            }
          ],
          segments: []
        }
      ]
    }
    information {
      {
        website_url: Faker::Internet.url,
        formatted_phone: Faker::PhoneNumber.phone_number,
        price_tier: rand(1..4),
        reservations_url: Faker::Internet.url,
        menu_url: Faker::Internet.url,
        menu_mobile_url: Faker::Internet.url,
        reservations: 'Yes',
        credit_cards: 'Yes (incl. American Express)',
        outdoor_seating: 'Yes',
        dining_options: 'Take-out',
        dress_code: 'No Pants',
        dining_style: 'Casual Dining',
        public_transit: 'Take the bus.',
        parking: 'Street Parking',
        parking_details: 'Some Parking deetz.'
      }
    }

    factory :existing_place, class: Place do
      last_imported_at { 15.days.ago }
    end
  end

  factory :big_star do
    association(:creator, factory: :user)

    name 'Big Star'
    address '1531 N Damen Ave'
    city 'Chicago'
    state 'IL'
    postal_code '60622'
    country 'United States'
    facebook_page_id '162760584142'
    twitter_username 'bigstarchicago'
    foursquare_venue_id '4adbf2bbf964a520242b21e3'
    foursquare_timeframes [
      {
        days: "Mon-Fri, Sun",
        includesToday: true,
        open: [
          {
            renderedTime: "11:30 AM-2:00 AM"
          }
        ],
        segments: []
      },
      {
        days: "Sat",
        open: [
          {
            renderedTime: "11:30 AM-3:00 AM"
          }
        ],
        segments: []
      }
    ]
    information {
      {
        website_url: "http://www.bigstarchicago.com",
        formatted_phone: '(773) 235-4039',
        price_tier: 2,
        reservations_url: "http://www.opentable.com/single.aspx?rid=20791&ref=9601",
        menu_url: "https://foursquare.com/v/big-star/4adbf2bbf964a520242b21e3/menu",
        menu_mobile_url: "https://foursquare.com/v/4adbf2bbf964a520242b21e3/device_menu",
        reservations: "Yes",
        credit_cards: "Yes (incl. American Express)",
        outdoor_seating: "Yes",
        dining_options: "Take-out; No Delivery",
        dress_code: "Casual Dress",
        dining_style: "Casual Dining",
        public_transit: "Take the bus.",
        parking: "Street Parking",
        parking_details: "We don't have valet or private parking. We recommend street parking or side streets."
      }
    }
  end
end
