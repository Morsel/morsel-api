FactoryGirl.define do
  factory :keyword do
    name { "keyword_#{Faker::Lorem.characters(10)}" }
  end

  factory :cuisine do
    name { "cuisine_#{Faker::Lorem.characters(10)}" }
    type 'Cuisine'
  end

  factory :specialty do
    name { "specialty_#{Faker::Lorem.characters(10)}" }
    type 'Specialty'
  end
end
