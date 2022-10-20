class Api::V1::ProductsController < ApplicationController
  include ProductSupport
  include Pagination

  before_action :set_user, except: %i[index show]
  before_action :set_product, only: %i[show update destroy]
  before_action :create_query, only: %i[index]
  before_action :require_user_sign_in!, only: %i[create update destroy]
  before_action :require_user_is_seller!, only: %i[create update destroy]
  before_action :require_user_is_author!, only: %i[update destroy]


  def index
    @products = Product.includes(:seller).all.offset(@per_page * (@page - 1)).limit(@per_page)

    render json: {
      products: @products,
    }, status: :ok
  end

  def show
    render json: {
      product: @product,
    }, status: :ok
  end


  def create
    @product = Product.new(product_params)
    @product.seller_id = @user.id 

    if @product.save
      render json: {
        message: "create product successfully",
        product: @product
      }, status: 201
    else
      render json: {
        message: "create product failed",
        errors: @product.errors
      }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: {
        message: "updated product successfully",
        product: @product,
        user: @user
      }, status: :ok
    else
      render json: {
        message: "updated product failed",
        errors: @product.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      render json: {
        message: "product delete successfully"
      }, status: :ok
    else
      render json: {
        errors: ["something is wrong"]
      }, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:product_name, :amount_aviable, :cost)
  end
end

