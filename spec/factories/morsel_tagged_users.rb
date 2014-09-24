FactoryGirl.define do
  factory :morsel_tagged_user do
    association(:morsel)
    association(:user)
  end
end
