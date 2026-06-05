Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  get "/auth/github", to: "github_auth#show", as: :github_auth

  ActiveAdmin.routes(self)

  root "home#index"

  resources :rooms, only: %i[index show]
  resources :bookings, only: %i[new create]
  get "my_bookings", to: "my_bookings#index", as: :my_bookings

  namespace :owner do
    resources :rooms
  end
end
