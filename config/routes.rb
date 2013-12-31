MorselApp::Application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  devise_for :users

  namespace :api do
    devise_for :users, controllers: { sessions: 'api/sessions', registrations: 'api/registrations' }
    resources :users, only: [ :create, :index, :show, :update ]
    resources :morsels, only: [ :create, :index, :show, :update ]
  end
end
