require 'rails_helper'
require 'faker'

RSpec.describe Api::V1::ProductsController, type: :request do
  subject(:buyer) { create(:buyer) }
  subject(:seller) { create(:seller) }
  let(:buyer_token) { AccessToken.encode(user_id: buyer.id) }
  let(:seller_token) { AccessToken.encode(user_id: seller.id) }
  
  before do
    create_products
  end

  describe 'GET /index' do
    let(:root) { '/api/v1/products'}

    context 'page and per page not input' do
      before do
        get root
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['products'].size).to eq(5)}
      it { expect(json['products'].map{|product| product['id'] }).to eq(products_ids(0, 5))}
    end

    context 'page input but per page not input' do
      let(:page) { Faker::Number.within(range: 1..100)}
      before do
        get root,
        params: {
          query: {
            page: page
          }
        }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['products'].map{|product| product['id'] }).to eq(products_ids(page - 1 , 5))}
    end

    context 'page not input but per page is input' do
      let(:per_page) { Faker::Number.within(range: 1..100) }
      before do
        get root,
        params: {
          query: {
            per_page: per_page
          }
        }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['products'].map{|product| product['id'] }).to eq(products_ids(0, per_page))}
    end

    context 'page and per page is input' do
      let(:page) { Faker::Number.within(range: 1..10) }
      let(:per_page) { Faker::Number.within(range: 1..10) }

      before do
        get root,
        params: {
          query: {
            per_page: per_page,
            page: page
          }
        }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['products'].map{|product| product['id'] }).to eq(products_ids(page - 1, per_page))}
    end
  end

  describe 'GET /show' do
    let(:root) { '/api/v1/products/'}

    context 'product_id not found' do
      before do
        get root + invalid_product_id.to_s
      end

      it { expect(response).to have_http_status(404) }
      it { expect(json['errors']).to eq(["Product not found"]) }
    end

    context 'product_id exist' do
      let(:product_id) { valid_product_id }

      before do
        get root + product_id.to_s
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['product']['id']).to eq(product_id) }
    end
  end

  describe 'POST /create' do
    let(:root) { '/api/v1/products'}

     context 'unauthorized user' do
      before do
        post root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'user is not seller' do
      before do
        post root,
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be seller"]) }
    end

    context 'user is seller and params is valid' do
      before do
        post root,
        params: valid_params,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(json['message']).to eq("create product successfully")}
      it { expect(json['product']['id']).not_to be_nil }
    end

    context 'user is seller but product name is blank' do 
      before do
        post root,
        params: product_name_invalid_params,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("create product failed")}
      it { expect(json['errors']['product_name']).to eq(["can't be blank"])}
    end

    context 'user is seller but amount is negative' do 
      before do
        post root,
        params: negative_amount_params,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("create product failed")}
      it { expect(json['errors']['amount_aviable']).to eq(["must be greater than or equal to 0"]
)}
    end

    context 'user is seller but cost is invalid' do 
      before do
        post root,
        params: invalid_cost_params,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("create product failed")}
      it { expect(json['errors']['cost']).to eq(["cost should be in multiples of 5"])}
    end
  end

  describe 'PUT /update' do
    let(:product) { create(:product, seller: seller) }
    let(:product_id) { product.id }
    let(:root) { '/api/v1/products/' + product_id.to_s }

     context 'unauthorized user' do
      before do
        put root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'product_id not found' do
      before do
        get '/api/v1/products/' + (product_id + 1).to_s
      end

      it { expect(response).to have_http_status(404) }
      it { expect(json['errors']).to eq(["Product not found"]) }
    end

    context 'user is not seller' do
      before do
        put root,
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be seller"]) }
    end

    context 'product author is not user' do
      let(:unpermited_seller) { create(:seller) }
      let(:unpermited_seller_token) { AccessToken.encode(user_id: unpermited_seller.id) }
      
      before do
        put root,
        headers: { 'Authorization': unpermited_seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You are not allowed"]) }
    end

    context 'user is seller and product_name is valid' do
      before do
        put root,
        params: {
          product: {
            product_name: "update product"
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("updated product successfully")}
      it { expect(json['product']['product_name']).to eq("update product") }
    end

    context 'user is seller but product name is blank' do 
      before do
        put root,
        params: {
          product: {
            product_name: ""
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("updated product failed")}
      it { expect(json['errors']['product_name']).to eq(["can't be blank"])}
    end

     context 'user is seller and amount_aviable is valid' do
      before do
        put root,
        params: {
          product: {
            amount_aviable: 12
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("updated product successfully")}
      it { expect(json['product']['amount_aviable']).to eq(12) }
    end

    context 'user is seller but amount is negative' do 
      before do
        put root,
        params: {
          product: {
            amount_aviable: -1
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("updated product failed")}
      it { expect(json['errors']['amount_aviable']).to eq(["must be greater than or equal to 0"]
)}
    end

     context 'user is seller and cost is valid' do
      before do
        put root,
        params: {
          product: {
            cost: 10
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("updated product successfully")}
      it { expect(json['product']['cost']).to eq(10) }
    end

    context 'user is seller but cost is invalid' do 
      before do
        put root,
        params: {
          product: {
            cost: 9
          }
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['message']).to eq("updated product failed")}
      it { expect(json['errors']['cost']).to eq(["cost should be in multiples of 5"])}
    end
  end

  describe 'DELETE /destroy' do
    let(:product) { create(:product, seller: seller) }
    let(:product_id) { product.id }
    let(:root) { '/api/v1/products/' + product_id.to_s }

     context 'unauthorized user' do
      before do
        delete root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'user is not seller' do
      before do
        delete root,
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be seller"]) }
    end

    context 'product_id not found' do
      before do
        get '/api/v1/products/' + (product_id + 1).to_s
      end

      it { expect(response).to have_http_status(404) }
      it { expect(json['errors']).to eq(["Product not found"]) }
    end

    context 'product author is not user' do
      let(:unpermited_seller) { create(:seller) }
      let(:unpermited_seller_token) { AccessToken.encode(user_id: unpermited_seller.id) }
      
      before do
        delete root,
        headers: { 'Authorization': unpermited_seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You are not allowed"]) }
    end

    context 'product author is user' do
      before do
        delete root,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("product delete successfully")}
    end
  end
end


