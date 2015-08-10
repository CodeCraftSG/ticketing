FactoryGirl.define do
  factory :event do
    name Faker::Lorem.sentence
    start_date Faker::Date.forward(100)
    end_date { start_date + 3.days }
    daily_start_time '8am'
    daily_end_time '5pm'
    description Faker::Lorem.paragraph
    active true
  end
end
