class Api::V1::DepositsController < ApplicationController
  VALIDATE_COINS = [5, 10, 20, 50, 100]

  include AuthenticateUser

  before_action :set_user
  before_action :set_product, only: %i[buy]
  before_action :require_user_sign_in!
  before_action :require_user_is_buyer!
  before_action :validate_coin, only: %i[update]


  def show
    render json: {
      message: "#{@user.username} deposit",
      deposit: @user.deposit
    }
  end

  def update
    @user.deposit += params[:coin].to_i
    
    if @user.save
      render json: {
        message: "deposit update successfully",
        deposit: @user.deposit
      }
    else
      render json: {
        message: "deposit update failed",
        errors: @user.errors
      }
    end
  end

  def destroy
    @user.deposit = 0

    if @user.save
      render json: {
        message: "deposit update successfully",
        deposit: @user.deposit
      }
    else
      render json: {
        message: "deposit update failed",
        errors: @user.errors
      }
    end
  end

  def buy
    amount = params[:amount].to_i
    cost = @product.cost
    total_price = amount * cost

    if change_deposit(total_price, amount)
      render json: {
        message: "buy #{amount} #{@product.product_name}",
        product: @product,
        total: total_price,
        change: change
      }
    else
      render json: {
        errors: ["You have not enough money"],
        total_price: total_price,
        deposit: @user.deposit
      }, status: :unprocessable_entity
    end
  end

  private

  def validate_coin
    render json: {
      errors: "coin value is not validate"
    }, status: :unprocessable_entity unless VALIDATE_COINS.any? { |coin| coin == params[:coin].to_i}
  end

  def set_product
    @product = Product.find_by(id: params[:product_id])

    render json: {
      errors: ["Product not found"]
    }, status: 404 unless @product
  end

  def require_user_is_buyer!
     render json: {
      errors: ["You have to be buyer"]
    }, status: :unauthorized unless @user.buyer?
  end

  def require_user_sign_in!
    render json: {
      errors: ["You have to sign in first"]
    }, status: :unauthorized unless @user
  end

  def change
    deposit = @user.deposit
    changes = []

    VALIDATE_COINS.reverse.each do |coin|
      count = deposit / coin
      deposit -= count * coin
      count.times do
        changes << coin
      end
    end

    changes
  end

  def change_amount(amount)
    return false if amount > @product.amount_aviable

    @product.amount_aviable -= amount
    @product.save 
  end

  def change_deposit(total_price, amount)
    return false if total_price > @user.deposit || !change_amount(amount)

    @user.deposit -= total_price
    @user.save
  end
end
