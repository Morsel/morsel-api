require 'sidekiq/web'

MorselApp::Application.routes.draw do
  root to: 'status#index'
  get 'status' => 'status#index'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  ActiveAdmin.routes(self)

  devise_for  :users,
              controllers: {
                sessions: 'sessions',
                registrations: 'registrations'
              }

  resources :users, only: [:index, :update] do
    resources :authorizations, only: [:index]
  end

  post 'users/authorizations' => 'authorizations#create'
  get 'users/checkusername(/:username)' => 'users#checkusername'
  get 'users/me' => 'users#me'
  get 'users/:user_id_or_username' => 'users#show'
  get 'users/:user_id_or_username/posts' => 'posts#index'

  resources :morsels, only: [:create, :show, :update, :destroy] do
    resources :comments, only: [:create, :index]
  end
  get 'feed' => 'morsels#index'
  get 'users/:user_id_or_username/feed' => 'morsels#index'
  resources :comments, only: [:destroy]

  post 'morsels/:morsel_id/like', to: 'likes#create'
  delete 'morsels/:morsel_id/like', to: 'likes#destroy'

  resources :posts, only: [:index, :show, :update] do
    resources :morsels, only: [:update, :destroy]
  end

  post 'posts/:id/append', to: 'posts#append'
  delete 'posts/:id/append', to: 'posts#unappend'

  resources :subscribers, only: [:create]
end
