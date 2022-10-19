class Api::V1::Users::RegistrationsController < ApplicationController
  include AccessToken
  include AuthenticateUser
  before_action :set_user, only: %i[update destroy]

  def create
    @user = User.new(user_params)

    if @user.save
      render json: {
        message: "Sign up Successfully",
        user: @user,
        access_token: AccessToken.encode(user_id: @user.id)
      }, status: 201
    else
      render json: {
        message: "Sign up failed",
        errors: @user.errors
      }, status: :unprocessable_entity
    end
  end


  def update
    if @user&.update_with_password(user_params_for_update)
      render json: {
        message: "User update Successfully",
        user: @user,
        access_token: AccessToken.encode(user_id: @user.id)
      }, status: :ok
    else
      render json: {
        message: "User update failed",
        errors: @user ? @user.errors : "You have to sign in first",
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user&.destroy
      render json: {
        message: 'delete account successfully'
      }, status: :ok
    else
      render json: {
        message: 'delete account failed',
        errors: @user ? @user.errors : 'user not found'
      }, status: :unprocessable_entity
    end 
  end

  private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :role)
    end

    def user_params_for_update
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password, :role)
    end
end