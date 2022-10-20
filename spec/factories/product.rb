FactoryBot.define do
  factory :product do
    product_name { Faker::Name.name }
    amount_aviable { Faker::Number.within(range: 1..100) }
    cost { Faker::Number.within(range: 1..20) * 5 }
    association :seller
  end
end