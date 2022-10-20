require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  let(:root) { 'api/v1/' }

  it 'route to #show' do
    expect(get: root + 'deposit').to route_to(root + 'deposits#show')
  end

  it 'route to #update' do
    expect(put: root + 'deposit').to route_to(root + 'deposits#update')
  end

  it 'route to #destroy' do
    expect(delete: root + 'reset').to route_to(root + 'deposits#destroy')
  end 

  it 'route to #buy' do
    expect(post: root+ 'buy').to route_to(root + 'deposits#buy')
  end
end

