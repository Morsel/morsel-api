FactoryGirl.define do
  factory :foursquare_venue do
    skip_create

    id { Faker::Lorem.characters(10) }
    name { Faker::Company.name }
    location {{
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr
    }}
  end
end
