require 'sidekiq/web'

MorselApp::Application.routes.draw do
  root to: 'status#show'
  get 'status' => 'status#show'
  get 'configuration' => 'configuration#show'

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
    collection do
      post 'authorizations' => 'authorizations#create'
      get 'checkusername(/:username)' => 'users#checkusername'
      get 'me' => 'users#me'
      get ':user_id_or_username' => 'users#show'
      get ':user_id_or_username/posts' => 'posts#index'
      get ':user_id_or_username/feed' => 'morsels#index'
    end
    resources :authorizations, only: [:index]
  end

  resources :morsels, only: [:create, :show, :update, :destroy] do
    collection do
      get 'drafts' => 'morsels#drafts'
    end
    resources :comments, only: [:create, :index]
  end
  get 'feed' => 'morsels#index'
  post 'morsels/:morsel_id/like', to: 'likes#create'
  delete 'morsels/:morsel_id/like', to: 'likes#destroy'

  resources :comments, only: [:destroy]

  resources :posts, only: [:index, :show, :update] do
    collection do
      post ':id/append', to: 'posts#append'
      delete ':id/append', to: 'posts#unappend'
    end
    resources :morsels, only: [:update, :destroy]
  end

  resources :subscribers, only: [:create]
end
