require 'faker'

FactoryBot.define do
  factory :buyer, class: User do
    username { Faker::Name.unique.name }
    email { Faker::Internet.unique.email}
    password { 'buyer_password' }
    password_confirmation { 'buyer_password' }
  end

  factory :seller, class: User do
    username { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    password { 'seller_password' }
    password_confirmation { 'seller_password' }
    role { 1 }
  end
end
