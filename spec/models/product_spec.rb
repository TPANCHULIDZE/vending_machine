require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { create(:product) }
  
  context 'belongs to Seller' do
    it { should belong_to(:seller).class_name('User').with_foreign_key(:seller_id) }
  end

  context 'have validate product name' do
    it { should validate_presence_of(:product_name) }
  end

  context 'have validate amount aviable' do
    it { should validate_presence_of(:amount_aviable) }
     it { should validate_numericality_of(:amount_aviable).is_greater_than_or_equal_to(0) }
  end

  context 'have validate cost' do
    it { should validate_presence_of(:cost) }
    it { should validate_numericality_of(:cost).is_greater_than_or_equal_to(0) }
  end
end