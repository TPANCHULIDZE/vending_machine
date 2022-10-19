class User < ApplicationRecord
  
  has_many :products, foreign_key: :seller_id, dependent: :destroy


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: %i[buyer seller]

  validates :username, presence: true
  validates :deposit, presence: true
  validates :role, presence: true, inclusion: { in: %w(buyer seller)}

  private

    def set_default_status
      self.status ||= :buyer
    end
end
