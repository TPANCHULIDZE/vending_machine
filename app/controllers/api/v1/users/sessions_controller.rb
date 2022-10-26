class Api::V1::Users::SessionsController < ApplicationController
  include AccessToken

  def create
    @user = User.find_by(username: user_params[:username])

    if @user&.valid_password?(user_params[:password])
      render json: {
        message: "Login Successfully",
        user: @user,
        access_token: AccessToken.encode({username: @user.username, password: user_params[:password]})
      }, status: :ok
    else
      render json: {
        message: "Login user failed",
        errors: "Incorrect username or password"
      }, status: :unauthorized
    end
  end


  private

    def user_params
      params.require(:user).permit(:username, :password)
    end
end

