FactoryBot.define do
  factory :attendee do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email Faker::Internet.email
    twitter Faker::Internet.user_name
    github Faker::Internet.user_name
    size %w(XS S M L XL XXL).sample
  end
end
