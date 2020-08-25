FactoryBot.define do
  factory :user do
    username { Faker::Lorem.unique.word.downcase }
    display_name { Faker::FunnyName.unique.name }
    email { Faker::Internet.email }
    admin { false }
    client { false }
    read_only { false }

    factory :admin do
      admin { true }
    end
    factory :client do
      client { true }
    end
  end
end
