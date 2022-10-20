Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :users do
        post '/', to: "registrations#create"
        put '/', to: "registrations#update"
        delete '/', to: "registrations#destroy"
        post '/login', to: "sessions#create"
      end

      get '/deposit', to: "deposits#show"
      put '/deposit', to: "deposits#update" 
      delete '/reset', to: "deposits#destroy"
      post '/buy', to: "deposits#buy"

      get '/products', to: "products#index"
      get '/products/:product_id', to: "products#show"
      post '/products', to: "products#create"
      put '/products/:product_id', to: "products#update"
      delete '/products/:product_id', to: "products#destroy"
    end
  end
end
