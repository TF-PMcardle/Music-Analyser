Rails.application.routes.draw do
  get 'musics/index'
  get 'musics/new'
  get 'musics/create'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :musics

  root 'musics#index'  # Set the root path to the index action of MusicsController
end

