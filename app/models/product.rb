class Product < ApplicationRecord
  belongs_to :seller, class_name: "User", foreign_key: :seller_id

  validates :product_name, presence: true, allow_blank: false
  validates :amount_aviable, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates_each :cost do |record, attr, value|
    record.errors.add attr, "cost should be in multiples of 5" unless !value || value % 5 == 0
  end
end


