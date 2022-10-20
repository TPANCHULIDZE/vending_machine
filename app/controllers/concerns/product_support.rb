
module ProductSupport
  include AuthenticateUser

  private

  def set_product
    @product = Product.includes(:seller).find_by(id: params[:product_id])

    render json: {
      errors: ["Product not found"]
    }, status: 404 unless @product
  end

  def require_user_sign_in!
    render json: {
      errors: ["You have to sign in first"]
    }, status: :unauthorized unless @user
  end

  def require_user_is_author!
    render json: {
      errors: ["You are not allowed"]
    }, status: :unauthorized if @user.id != @product.seller_id
  end

  def require_user_is_seller!
    render json: {
      errors: ["You have to be seller"]
    }, status: :unauthorized unless @user.seller?
  end
end

