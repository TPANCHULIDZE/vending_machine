require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  let(:root) { 'api/v1/products' }
  let(:product) { create(:product) }
  let(:product_id) { product.id.to_s }

  it 'route to #index' do
    expect(get: root).to route_to(root + '#index')
  end

  it 'route to #show' do
    expect(get: root + '/' + product_id).to route_to(root + '#show', product_id: product_id)
  end

  it 'route to #create' do
    expect(post: root).to route_to(root + '#create')
  end

  it 'route to #update' do
    expect(put: root + '/' + product_id).to route_to(root + '#update', product_id: product_id)
  end

  it 'route to #destroy' do
    expect(delete: root + '/' + product_id).to route_to(root + '#destroy', product_id: product_id)
  end
end