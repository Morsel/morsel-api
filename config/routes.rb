MorselApp::Application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  devise_for :users

  namespace :api do
    devise_for  :users,
                controllers: {
                  sessions: 'api/sessions',
                  registrations: 'api/registrations'
                }

    resources :users, only: [:index, :show, :update] do
      resources :morsels, only: [:index]
      resources :posts, only: [:index]
    end

    resources :morsels, only: [:create, :index, :show, :update, :destroy]

    post 'morsels/:morsel_id/like', to: 'likes#create'
    delete 'morsels/:morsel_id/like', to: 'likes#destroy'

    resources :posts, only: [:index, :show, :update] do
      resources :morsels, only: [:update, :destroy]
    end

    post 'posts/:id/append', to: 'posts#append'
    delete 'posts/:id/append', to: 'posts#unappend'
  end
end
