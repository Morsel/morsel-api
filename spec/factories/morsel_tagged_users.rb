FactoryGirl.define do
  factory :morsel_tagged_user do
    association(:morsel, factory: :morsel_with_creator)
    association(:user)
  end
end
