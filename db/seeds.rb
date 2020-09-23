# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# create users
admin = User.create!(username: :admin,
                     admin: true,
                     display_name: Faker::Name.unique.name,
                     email: Faker::Internet.unique.email)

clients = 10.times.map do
  client = User.create!(username: Faker::Name.unique.first_name.downcase,
                        display_name: Faker::Name.unique.name,
                        email: Faker::Internet.unique.email,
                        client: true)
end


# create locations
locations = 3.times.map do
  Location.create!(name: "BA#{Faker::Address.building_number}",
                   description: Faker::Movies::HitchhikersGuideToTheGalaxy.unique.location)
end


# create resources and availabilities
past_availabilities = []
future_availabilities = []
10.times.map do
  resource = Resource.create!(resource_type: Faker::Appliance.equipment,
                              name: Faker::NatoPhoneticAlphabet.unique.code_word,
                              location: locations.sample)
  10.times.map do |i|
    start_time = i.days.ago.beginning_of_day
    avail = Availability.create!(resource: resource, start_time: start_time, end_time: start_time + 1.day - 1.second)
    past_availabilities << avail
  end
  4.times.map do |i|
    start_time = (i+1).days.from_now.beginning_of_day
    avail = Availability.create!(resource: resource, start_time: start_time, end_time: start_time + 1.day - 1.second)
    future_availabilities << avail
  end
end

# create availabilities
clients.each do |client|
  rand(max=10).times.each do
    Booking.create(user: client, creator: client, availability: past_availabilities.delete(past_availabilities.sample))
  end
  if [true, false].sample
    Booking.create!(user: client,
                    creator: client,
                    availability: future_availabilities.delete(future_availabilities.sample))
  end
end
