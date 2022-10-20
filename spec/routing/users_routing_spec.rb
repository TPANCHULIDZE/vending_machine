require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  let(:root) { 'api/v1/users/' }

  context 'registrations' do

    it 'route to #create' do
      expect(post: root).to route_to(root + 'registrations#create')
    end

    it 'route to #update' do
      expect(put: root).to route_to(root + 'registrations#update')
    end

    it 'route to #destroy' do
      expect(delete: root).to route_to(root + 'registrations#destroy')
    end
  end

  context 'sessions' do
    it 'route to #create' do
      expect(post: root + 'login').to route_to(root + 'sessions#create')
    end
  end
end