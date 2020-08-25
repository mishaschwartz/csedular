FactoryBot.define do
  factory :booking do
    association :user, factory: :client
    association :creator, factory: :admin
    association :availability

    factory :future_booking do
      association :availability, factory: :future_availability
    end
  end
end
