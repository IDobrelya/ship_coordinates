Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    namespace :api do
      post '/flush', to: 'system#flush'

      get '/ships', to: 'ships#index'
      get '/ships/:id', to: 'ships#show'
      post '/ships/:id/position', to: 'ships#position'
    end
  end
end
