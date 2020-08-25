FactoryBot.define do
  factory :resource do
    association :location
    resource_type { Faker::Food.unique.spice }
    name { Faker::Food.unique.vegetables }
  end
end
