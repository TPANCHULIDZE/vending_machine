require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User' do
    subject(:buyer) { create(:buyer) }
    subject(:seller) { create(:seller) }
    
    context 'have many products' do
      it { should have_many(:products).dependent(:destroy).with_foreign_key(:seller_id) }
    end

    context 'have validate username' do
      it { should validate_presence_of(:username) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    context 'have validate email' do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    context 'have validate password' do
      it { should validate_length_of(:password).is_at_least(6).on(:create) }
      it { should validate_confirmation_of(:password) }
    end

    context 'have validate status' do
      it { should validate_presence_of(:role)}
      it { should define_enum_for(:role).with_values(%i[buyer seller]) }
    end

    context 'have validate deposit' do
      it { should validate_presence_of(:deposit) }
      it { should validate_numericality_of(:deposit).is_greater_than_or_equal_to(0) }
    end
  end
end

