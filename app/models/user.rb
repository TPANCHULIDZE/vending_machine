class User < ApplicationRecord
  
  has_many :products, foreign_key: :seller_id, dependent: :destroy


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: %i[buyer seller]

  validates :username, presence: true, allow_blank: false
  validates :deposit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :role, presence: true, inclusion: { in: %w(buyer seller)}


  validates_each :deposit do |record, attr, value|
    record.errors.add attr, "deposit should be in multiples of 5" unless !value || value % 5 == 0
  end
end

