require 'faker'

module ProductsSpecHelper
  def create_products
    100.times do
      create(:product)
    end
  end

  def products_ids(page, limit)
    Product.all.offset(page * limit).limit(limit).map {|product| product.id }
  end

  def valid_product_id
    Product.first.id + Faker::Number.within(range: 0..99)
  end

  def invalid_product_id
    Product.last.id + 1
  end

  def valid_params
    {
      product: {
        product_name: Faker::Name.name,
        amount_aviable: Faker::Number.within(range: 1..100),
        cost: Faker::Number.within(range: 1..20) * 5
      }
    }
  end

  def negative_amount_params
    { 
      product: {
        product_name: Faker::Name.name, 
        amount_aviable: -1 * Faker::Number.within(range: 1..100),
        cost: Faker::Number.within(range: 1..20) * 5 
      }
    }
  end

  def invalid_cost_params
    {
      product: {
        product_name: Faker::Name.name,
        amount_aviable: Faker::Number.within(range: 1..100),
        cost: Faker::Number.within(range: 1..20) * 5 + Faker::Number.within(range: 1..4)
      }
    }
  end

  def product_name_invalid_params
    {
      product: {
        product_name: "",
        amount_aviable: Faker::Number.within(range: 1..100),
        cost: Faker::Number.within(range: 1..20) * 5
      }
    }
  end
end


