FactoryGirl.define do
  factory :user_tag, class: Tag do
    association(:tagger, factory: :user)
    association(:taggable, factory: :user)
    association(:keyword, factory: :keyword)

    factory :user_cuisine_tag, class: Tag do
      association(:keyword, factory: :cuisine)
    end

    factory :user_specialty_tag, class: Tag do
      association(:keyword, factory: :specialty)
    end
  end
end
