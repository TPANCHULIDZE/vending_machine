
module AuthenticateUser 
  def set_user
    header = JSON.parse(request.headers['Authorization'].to_json)
    
    return nil if header.nil?

    decoded = AccessToken.decode(header)

    @user = check_user(decoded)
  end

  private

    def check_user(decoded)
      user = User.find_by(username: decoded[:username])

      if user&.valid_password?(decoded[:password])
        return user
      else
        return nil
      end
    end
end

