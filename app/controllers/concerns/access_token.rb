
module AccessToken
  SECRET_KEY = Rails.application.credentials[:jwt_secret_key].to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, false).first
    HashWithIndifferentAccess.new decoded
  rescue
    return {user_id: nil}
  end
end
