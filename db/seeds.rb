require 'faker'

def create_seller
  password = Faker::Internet.password(min_length: 8)
  User.create(
    username: Faker::Name.unique.name,
    email: Faker::Internet.unique.email,
    password: password,
    password_confirmation: password,
    role: 1
  )
end

def create_buyer
  password = Faker::Internet.password(min_length: 8)
  User.create(
    username: Faker::Name.unique.name,
    email: Faker::Internet.unique.email,
    password: password,
    password_confirmation: password,
    deposit: Faker::Number.within(range: 1..100) * 5
  )
end

def create_product(seller_id)
  Product.create(
    product_name: Faker::Alphanumeric.alpha(number: Faker::Number.within(range: 1..20)),
    amount_aviable: Faker::Number.within(range: 1..100),
    cost: Faker::Number.within(range: 1..20) * 5,
    seller_id: seller_id
  )
end

50.times do
  seller = create_seller
  10.times do
    create_product(seller.id)
  end
  create_buyer
end