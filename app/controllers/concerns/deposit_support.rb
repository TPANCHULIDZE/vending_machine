module DepositSupport
  VALIDATE_COINS = [5, 10, 20, 50, 100]

  include AuthenticateUser
  
  private

  def validate_coin
    render json: {
      errors: ["coin value is not validate"]
    }, status: :unprocessable_entity unless VALIDATE_COINS.include? params[:coin].to_i
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

