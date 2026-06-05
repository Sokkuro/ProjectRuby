FactoryBot.define do
  factory :room do
    sequence(:name) { |n| "Room #{n}" }
    location { "Moscow" }
    price_per_hour { 500 }
    is_active { true }
    association :user, factory: :user, traits: [:owner]
  end
end
