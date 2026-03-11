Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/auth", to: "auth#auth"
  get "/auth/callback", to: "auth#callback"

  post "/webhooks/orders_create", to: "webhooks#orders_create"
  post "/webhooks/app_uninstalled", to: "webhooks#app_uninstalled"

  post "/billing/create", to: "billing#create"
  post "/billing/confirm", to: "billing#confirm"

  namespace :api do
    namespace :v1 do
      get "/products", to: "products#index"
      post "/products/sync", to: "products#sync"
    end
  end
end
