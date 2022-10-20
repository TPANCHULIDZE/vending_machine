class Api::V1::DepositsController < ApplicationController
  include DepositSupport

  before_action :set_user
  before_action :set_product, only: %i[buy]
  before_action :require_user_sign_in!
  before_action :require_user_is_buyer!
  before_action :validate_coin, only: %i[update]


  def show
    render json: {
      message: "#{@user.username} deposit",
      deposit: @user.deposit
    }, status: :ok
  end

  def update
    @user.deposit += params[:coin].to_i
    
    if @user.save
      render json: {
        message: "deposit update successfully",
        deposit: @user.deposit
      }, status: :ok
    else
      render json: {
        message: "deposit update failed",
        errors: @user.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.deposit = 0

    if @user.save
      render json: {
        message: "deposit reset successfully",
        deposit: @user.deposit
      }, status: :ok
    else
      render json: {
        message: "deposit reset failed",
        errors: @user.errors
      }, status: :unprocessable_entity
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
      }, status: :ok
    else
      render json: {
        errors: ["You have not enough money or amount is not aviable"],
        total_price: total_price,
        deposit: @user.deposit,
        amount: amount,
        amount_aviable: @product.amount_aviable
      }, status: :unprocessable_entity
    end
  end
end


