FactoryBot.define do
  factory :availability do
    association :resource
    start_time { Time.now }
    end_time { Time.now + 1.hour }

    factory :future_availability do
      start_time { Time.now + 2.hour }
      end_time { Time.now + 3.hours }
    end
  end
end
