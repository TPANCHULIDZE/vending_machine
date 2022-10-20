require 'rails_helper'

RSpec.describe Api::V1::DepositsController, type: :request do
  subject(:buyer) { create(:buyer) }
  subject(:seller) { create(:seller) }
  let(:buyer_token) { AccessToken.encode(user_id: buyer.id) }
  let(:seller_token) { AccessToken.encode(user_id: seller.id) }
  
  describe 'GET /deposit' do
    let(:root) { '/api/v1/deposit'}

    context 'unauthorized user' do
      before do
        get root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'user is not buyer' do
      before do
        get root,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be buyer"]) }
    end

    context 'user is buyer' do
      before do
        get root,
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("#{buyer.username} deposit")}
      it { expect(json['deposit']).to eq(buyer.deposit) }
    end
  end

  describe 'PUT /deposit' do
    let(:root) { '/api/v1/deposit' }

    context 'unauthorized user' do
      before do
        put root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'user is not buyer' do
      before do
        put root,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be buyer"]) }
    end

    context 'user is buyer and coin is validate' do
      before do
        put root, params: { coin: 5 }, headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("deposit update successfully")}
      it { expect(json['deposit']).to eq(buyer.deposit + 5) }
    end

    context 'user is buyer but coin is not validate' do
      before do
        put root, params: { coin: 13 }, headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['errors']).to eq(["coin value is not validate"])}
    end
  end

  describe 'DELETE /reset' do
    let(:root) { '/api/v1/reset' }

    context 'unauthorized user' do
      before do
        delete root
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'user is not buyer' do
      before do
        delete root,
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be buyer"]) }
    end    

    context 'user is buyer' do
      before do
        delete root,
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("deposit reset successfully")}
      it { expect(json['deposit']).to eq(0) }
    end
  end

  describe 'POST /buy' do
    let(:root) { '/api/v1/buy'}
    let(:product) { create(:product) }

    before do
      buyer.deposit = 100
      buyer.save
    end

    context 'unauthorized user' do
      before do
        post root,
        params: {
          product_id: product.id,
          amount: 0
        }
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to sign in first"]) }
    end

    context 'product not exist' do
      before do
        post root,
        params: {
          amount: 0
        },
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(404) }
      it { expect(json['errors']).to eq(["Product not found"]) }
    end

    context 'user is not buyer' do
      before do
        post root,
        params: {
          product_id: product.id,
          amount: 0
        },
        headers: { 'Authorization': seller_token } 
      end

      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(json['errors']).to eq(["You have to be buyer"]) }
    end

    context 'user is buyer but amount is not aviable' do
      before do
        post root,
        params: {
          amount: product.amount_aviable + 1,
          product_id: product.id
        },
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['errors']).to eq(["You have not enough money or amount is not aviable"])}
    end

    context 'user is buyer but deposit is not enough' do
      before do
        buyer.deposit = 0
        buyer.save
      end

      before do
        post root,
        params: {
          amount: product.amount_aviable - 1,
          product_id: product.id
        },
        headers: { 'Authorization': buyer_token } 
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json['errors']).to eq(["You have not enough money or amount is not aviable"])}
    end

    context 'user is buyer and have enough deposit and amount is aviable' do
      let(:new_product) { create(:product, cost: 25, amount_aviable: 10)}

      before do
        post root,
        params: {
          amount: 3,
          product_id: new_product.id
        },
        headers: { 'Authorization': buyer_token } 
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(json['message']).to eq("buy 3 #{new_product.product_name}")}
      it { expect(json['product']['id']).to eq(new_product.id) }
      it { expect(json['total']).to eq(3 * new_product.cost) }
      it { expect(json['change']).to eq([20, 5]) }
    end
  end
end