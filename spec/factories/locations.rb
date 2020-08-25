FactoryBot.define do
  factory :location do
    name { Faker::Food.unique.dish }
    description { Faker::Food.unique.description }
  end
end
